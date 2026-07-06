package com.hongmen.mall.payment.service;

import com.hongmen.mall.entity.Order;
import com.hongmen.mall.entity.Payment;
import com.hongmen.mall.payment.config.PaymentConfig;
import com.hongmen.mall.payment.dto.PayRequest;
import com.hongmen.mall.payment.dto.PayResponse;
import com.hongmen.mall.payment.dto.PaymentResultDTO;
import com.hongmen.mall.payment.enums.PaymentMethodEnum;
import com.hongmen.mall.payment.enums.PaymentStatusEnum;
import com.hongmen.mall.payment.strategy.PaymentStrategy;
import com.hongmen.mall.payment.strategy.PaymentStrategyFactory;
import com.hongmen.mall.repository.OrderRepository;
import com.hongmen.mall.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final OrderRepository orderRepository;
    private final PaymentStrategyFactory strategyFactory;
    private final PaymentConfig paymentConfig;

    @Transactional
    public PayResponse createPayRequest(PayRequest payRequest, String userId) {
        String orderId = payRequest.getOrderId();
        PaymentMethodEnum methodEnum = PaymentMethodEnum.getByCode(payRequest.getPaymentMethod());

        if (methodEnum == null) {
            throw new IllegalArgumentException("不支持的支付方式: " + payRequest.getPaymentMethod());
        }

        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("订单不存在: " + orderId));

        if (!order.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权操作此订单");
        }

        if (!"pending_payment".equals(order.getStatus())) {
            throw new IllegalArgumentException("订单状态不允许支付: " + order.getStatus());
        }

        List<Payment> oldPendingPayments = paymentRepository.findByOrderIdAndStatus(orderId, PaymentStatusEnum.PENDING.getCode());
        long now = System.currentTimeMillis();
        for (Payment old : oldPendingPayments) {
            old.setStatus(PaymentStatusEnum.CLOSED.getCode());
            old.setUpdatedAt(now);
        }
        if (!oldPendingPayments.isEmpty()) {
            paymentRepository.saveAll(oldPendingPayments);
            log.info("关闭旧的待支付记录: {} 条, orderId={}", oldPendingPayments.size(), orderId);
        }

        Payment payment = new Payment();
        payment.setPaymentId(UUID.randomUUID().toString().replace("-", ""));
        payment.setOrderId(orderId);
        payment.setOrderNo(order.getOrderNo());
        payment.setUserId(userId);
        payment.setAmount(BigDecimal.valueOf(order.getTotalAmount()));
        payment.setMethod(methodEnum.getCode());
        payment.setStatus(PaymentStatusEnum.PENDING.getCode());
        payment.setSubject("鸿蒙商城订单-" + order.getOrderNo());
        payment.setBody("订单金额: " + String.format("%.2f", order.getTotalAmount()) + "元");
        payment.setCreatedAt(now);
        payment.setUpdatedAt(now);
        paymentRepository.save(payment);

        PaymentStrategy strategy = strategyFactory.getStrategy(methodEnum);
        PayResponse response = strategy.pay(payment, order);
        response.setPaymentId(payment.getPaymentId());
        response.setOrderId(orderId);
        response.setPaymentMethod(methodEnum.getCode());
        return response;
    }

    @Transactional
    public PaymentResultDTO handleCallback(PaymentMethodEnum method, Map<String, String> params) {
        PaymentStrategy strategy = strategyFactory.getStrategy(method);
        PaymentResultDTO result = strategy.verifyCallbackAndParse(params);

        Optional<Payment> latestPaymentOpt = paymentRepository.findFirstByOrderNoOrderByCreatedAtDesc(result.getOrderNo());
        if (latestPaymentOpt.isEmpty()) {
            log.warn("回调订单不存在: {}", result.getOrderNo());
            return result;
        }

        Payment payment = latestPaymentOpt.get();

        if (PaymentStatusEnum.SUCCESS.getCode().equals(payment.getStatus())) {
            log.info("订单已支付，幂等返回: {}", result.getOrderNo());
            result.setStatus(PaymentStatusEnum.SUCCESS);
            result.setTransactionNo(payment.getTransactionNo());
            return result;
        }

        if (result.getStatus() == PaymentStatusEnum.SUCCESS) {
            payment.setStatus(PaymentStatusEnum.SUCCESS.getCode());
            payment.setTransactionNo(result.getTransactionNo());
            payment.setPaidAt(result.getPaidAt() != null ? result.getPaidAt() : System.currentTimeMillis());
            payment.setCallbackContent(params.toString());
            payment.setUpdatedAt(System.currentTimeMillis());
            paymentRepository.save(payment);

            Order order = orderRepository.findById(payment.getOrderId()).orElse(null);
            if (order != null) {
                order.setStatus("pending_shipment");
                order.setPaidAt(payment.getPaidAt());
                order.setUpdatedAt(System.currentTimeMillis());
                orderRepository.save(order);
            }

            log.info("支付成功: orderNo={}, transactionNo={}", result.getOrderNo(), result.getTransactionNo());
        } else if (result.getStatus() == PaymentStatusEnum.FAILED) {
            payment.setStatus(PaymentStatusEnum.FAILED.getCode());
            payment.setCallbackContent(params.toString());
            payment.setUpdatedAt(System.currentTimeMillis());
            paymentRepository.save(payment);
        }

        return result;
    }

    public PaymentResultDTO queryPaymentStatus(String orderId, String userId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("订单不存在"));

        if (!order.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权查询此订单");
        }

        Optional<Payment> paymentOpt = paymentRepository.findFirstByOrderIdOrderByCreatedAtDesc(orderId);
        PaymentResultDTO result = PaymentResultDTO.builder()
                .orderId(orderId)
                .orderNo(order.getOrderNo())
                .build();

        if (paymentOpt.isPresent()) {
            Payment payment = paymentOpt.get();
            result.setPaymentId(payment.getPaymentId());
            result.setPaidAmount(payment.getAmount().doubleValue());
            result.setTransactionNo(payment.getTransactionNo());
            result.setPaidAt(payment.getPaidAt());

            PaymentStatusEnum status = PaymentStatusEnum.PENDING;
            for (PaymentStatusEnum s : PaymentStatusEnum.values()) {
                if (s.getCode().equals(payment.getStatus())) {
                    status = s;
                    break;
                }
            }
            result.setStatus(status);

            if (status != PaymentStatusEnum.SUCCESS && status != PaymentStatusEnum.FAILED && status != PaymentStatusEnum.CLOSED) {
                PaymentMethodEnum payMethod = PaymentMethodEnum.getByCode(payment.getMethod());
                if (payMethod != null) {
                    boolean isMock = this.isMockMode(payMethod);
                    if (isMock) {
                        log.info("[MOCK] 支付轮询，直接标记支付成功: orderNo={}", payment.getOrderNo());
                        payment.setStatus(PaymentStatusEnum.SUCCESS.getCode());
                        payment.setTransactionNo("MOCK_" + payMethod.getCode().toUpperCase() + "_" + System.currentTimeMillis());
                        payment.setPaidAt(System.currentTimeMillis());
                        payment.setUpdatedAt(System.currentTimeMillis());
                        paymentRepository.save(payment);

                        order.setStatus("pending_shipment");
                        order.setPaidAt(payment.getPaidAt());
                        order.setUpdatedAt(System.currentTimeMillis());
                        orderRepository.save(order);

                        result.setStatus(PaymentStatusEnum.SUCCESS);
                        result.setTransactionNo(payment.getTransactionNo());
                        result.setPaidAt(payment.getPaidAt());
                    } else {
                        try {
                            PaymentStrategy strategy = strategyFactory.getStrategy(payMethod);
                            PaymentResultDTO queryResult = strategy.queryOrderStatus(payment);
                            if (queryResult.getStatus() == PaymentStatusEnum.SUCCESS) {
                                payment.setStatus(PaymentStatusEnum.SUCCESS.getCode());
                                payment.setTransactionNo(queryResult.getTransactionNo());
                                payment.setPaidAt(System.currentTimeMillis());
                                payment.setUpdatedAt(System.currentTimeMillis());
                                paymentRepository.save(payment);

                                order.setStatus("pending_shipment");
                                order.setPaidAt(payment.getPaidAt());
                                order.setUpdatedAt(System.currentTimeMillis());
                                orderRepository.save(order);
                                result.setStatus(PaymentStatusEnum.SUCCESS);
                                result.setTransactionNo(queryResult.getTransactionNo());
                            }
                        } catch (Exception e) {
                            log.error("查询支付状态失败", e);
                        }
                    }
                }
            }
        } else {
            result.setStatus(PaymentStatusEnum.PENDING);
        }

        return result;
    }

    @Transactional
    public PaymentResultDTO processSyncResult(String paymentId, String resultJson) {
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new IllegalArgumentException("支付记录不存在"));

        PaymentMethodEnum method = PaymentMethodEnum.getByCode(payment.getMethod());
        boolean isMock = this.isMockMode(method);

        long now = System.currentTimeMillis();

        if (isMock) {
            log.info("[MOCK] 收到前端同步结果，直接标记支付成功: paymentId={}, orderNo={}", paymentId, payment.getOrderNo());
            payment.setStatus(PaymentStatusEnum.SUCCESS.getCode());
            payment.setTransactionNo("MOCK_" + method.getCode().toUpperCase() + "_" + now);
            payment.setPaidAt(now);
            payment.setUpdatedAt(now);
            paymentRepository.save(payment);

            Order order = orderRepository.findById(payment.getOrderId()).orElse(null);
            if (order != null && "pending_payment".equals(order.getStatus())) {
                order.setStatus("pending_shipment");
                order.setPaidAt(now);
                order.setUpdatedAt(now);
                orderRepository.save(order);
            }

            return PaymentResultDTO.builder()
                    .paymentId(payment.getPaymentId())
                    .orderId(payment.getOrderId())
                    .orderNo(payment.getOrderNo())
                    .status(PaymentStatusEnum.SUCCESS)
                    .transactionNo(payment.getTransactionNo())
                    .paidAt(now)
                    .paidAmount(payment.getAmount().doubleValue())
                    .build();
        }

        payment.setStatus(PaymentStatusEnum.PROCESSING.getCode());
        payment.setUpdatedAt(now);
        paymentRepository.save(payment);

        PaymentStrategy strategy = strategyFactory.getStrategy(method);
        PaymentResultDTO result = strategy.parseSyncResult(payment, resultJson);

        if (result.getStatus() == PaymentStatusEnum.SUCCESS) {
            payment.setStatus(PaymentStatusEnum.SUCCESS.getCode());
            payment.setTransactionNo(result.getTransactionNo());
            payment.setPaidAt(result.getPaidAt() != null ? result.getPaidAt() : now);
            payment.setUpdatedAt(now);
            paymentRepository.save(payment);

            Order order = orderRepository.findById(payment.getOrderId()).orElse(null);
            if (order != null && "pending_payment".equals(order.getStatus())) {
                order.setStatus("pending_shipment");
                order.setPaidAt(payment.getPaidAt());
                order.setUpdatedAt(now);
                orderRepository.save(order);
            }
        } else if (result.getStatus() == PaymentStatusEnum.FAILED) {
            payment.setStatus(PaymentStatusEnum.FAILED.getCode());
            payment.setUpdatedAt(now);
            paymentRepository.save(payment);
        }

        return result;
    }

    private boolean isMockMode(PaymentMethodEnum method) {
        if (method == null) {
            return false;
        }
        switch (method) {
            case ALIPAY:
                return paymentConfig.getAlipay().isMock();
            case WECHAT_PAY:
                return paymentConfig.getWechat().isMock();
            case HUAWEI_PAY:
                return paymentConfig.getHuawei().isMock();
            default:
                return false;
        }
    }
}
