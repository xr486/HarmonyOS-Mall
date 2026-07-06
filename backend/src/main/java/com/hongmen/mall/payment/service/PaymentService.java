package com.hongmen.mall.payment.service;

import com.hongmen.mall.entity.Order;
import com.hongmen.mall.entity.Payment;
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
        long now = System.currentTimeMillis();
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

        Optional<Payment> paymentOpt = paymentRepository.findByOrderNo(result.getOrderNo());
        if (paymentOpt.isEmpty()) {
            log.warn("回调订单不存在: {}", result.getOrderNo());
            return result;
        }

        Payment payment = paymentOpt.get();

        if (PaymentStatusEnum.SUCCESS.getCode().equals(payment.getStatus())) {
            log.info("订单已支付，幂等返回: {}", result.getOrderNo());
            result.setStatus(PaymentStatusEnum.SUCCESS);
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
                order.setStatus("paid");
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

        Optional<Payment> paymentOpt = paymentRepository.findByOrderId(orderId);
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

            if (status != PaymentStatusEnum.SUCCESS && status != PaymentStatusEnum.FAILED) {
                PaymentMethodEnum method = PaymentMethodEnum.getByCode(payment.getMethod());
                if (method != null) {
                    try {
                        PaymentStrategy strategy = strategyFactory.getStrategy(method);
                        PaymentResultDTO queryResult = strategy.queryOrderStatus(payment);
                        if (queryResult.getStatus() == PaymentStatusEnum.SUCCESS) {
                            payment.setStatus(PaymentStatusEnum.SUCCESS.getCode());
                            payment.setTransactionNo(queryResult.getTransactionNo());
                            payment.setPaidAt(System.currentTimeMillis());
                            payment.setUpdatedAt(System.currentTimeMillis());
                            paymentRepository.save(payment);

                            order.setStatus("paid");
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
        PaymentStrategy strategy = strategyFactory.getStrategy(method);

        payment.setStatus(PaymentStatusEnum.PROCESSING.getCode());
        payment.setUpdatedAt(System.currentTimeMillis());
        paymentRepository.save(payment);

        return strategy.parseSyncResult(payment, resultJson);
    }
}
