package com.hongmen.mall.payment.service;

import com.hongmen.mall.entity.Payment;
import com.hongmen.mall.entity.PaymentRefund;
import com.hongmen.mall.payment.dto.PaymentRecordDTO;
import com.hongmen.mall.payment.dto.RefundRecordDTO;
import com.hongmen.mall.payment.dto.RefundRequest;
import com.hongmen.mall.payment.enums.PaymentStatusEnum;
import com.hongmen.mall.repository.PaymentRefundRepository;
import com.hongmen.mall.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentRecordService {

    private final PaymentRepository paymentRepository;
    private final PaymentRefundRepository refundRepository;

    public List<PaymentRecordDTO> getPaymentHistory(String userId) {
        return paymentRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(this::toPaymentRecordDTO)
                .collect(Collectors.toList());
    }

    public List<PaymentRecordDTO> getPaymentHistoryByOrder(String orderId) {
        return paymentRepository.findByOrderIdOrderByCreatedAtDesc(orderId).stream()
                .map(this::toPaymentRecordDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public RefundRecordDTO createRefund(RefundRequest request) {
        Payment payment = paymentRepository.findById(request.getPaymentId())
                .orElseThrow(() -> new IllegalArgumentException("支付记录不存在"));

        if (!PaymentStatusEnum.SUCCESS.getCode().equals(payment.getStatus())) {
            throw new IllegalStateException("只能对已支付成功的记录发起退款");
        }

        BigDecimal refundAmount = BigDecimal.valueOf(request.getAmount());
        if (refundAmount.compareTo(payment.getAmount()) > 0) {
            throw new IllegalArgumentException("退款金额不能超过支付金额");
        }

        BigDecimal alreadyRefunded = refundRepository.findByPaymentIdOrderByCreatedAtDesc(payment.getPaymentId())
                .stream()
                .filter(r -> PaymentStatusEnum.SUCCESS.getCode().equals(r.getStatus())
                        || PaymentStatusEnum.PROCESSING.getCode().equals(r.getStatus()))
                .map(PaymentRefund::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        if (refundAmount.add(alreadyRefunded).compareTo(payment.getAmount()) > 0) {
            throw new IllegalArgumentException("累计退款金额不能超过支付金额");
        }

        PaymentRefund refund = new PaymentRefund();
        refund.setRefundId(UUID.randomUUID().toString().replace("-", ""));
        refund.setPaymentId(payment.getPaymentId());
        refund.setOrderId(payment.getOrderId());
        refund.setTransactionNo(payment.getTransactionNo());
        refund.setRefundNo("RF" + System.currentTimeMillis() + String.format("%04d", (int)(Math.random() * 10000)));
        refund.setAmount(refundAmount);
        refund.setReason(request.getReason());
        refund.setStatus(PaymentStatusEnum.PROCESSING.getCode());
        long now = System.currentTimeMillis();
        refund.setCreatedAt(now);
        refund.setUpdatedAt(now);
        refundRepository.save(refund);

        if (refundAmount.add(alreadyRefunded).compareTo(payment.getAmount()) >= 0) {
            payment.setStatus(PaymentStatusEnum.REFUNDED.getCode());
            payment.setUpdatedAt(now);
            paymentRepository.save(payment);
        }

        log.info("退款创建成功: refundId={}, paymentId={}, amount={}", refund.getRefundId(), payment.getPaymentId(), refundAmount);

        return toRefundRecordDTO(refund);
    }

    public List<RefundRecordDTO> getRefundRecords(String orderId) {
        return refundRepository.findByOrderIdOrderByCreatedAtDesc(orderId).stream()
                .map(this::toRefundRecordDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public void confirmRefund(String refundId) {
        PaymentRefund refund = refundRepository.findById(refundId)
                .orElseThrow(() -> new IllegalArgumentException("退款记录不存在"));
        if (!PaymentStatusEnum.PROCESSING.getCode().equals(refund.getStatus())) {
            throw new IllegalStateException("只能确认处理中的退款");
        }
        refund.setStatus(PaymentStatusEnum.SUCCESS.getCode());
        refund.setUpdatedAt(System.currentTimeMillis());
        refundRepository.save(refund);
        log.info("退款确认成功: refundId={}", refundId);
    }

    private PaymentRecordDTO toPaymentRecordDTO(Payment p) {
        PaymentRecordDTO dto = new PaymentRecordDTO();
        dto.setPaymentId(p.getPaymentId());
        dto.setOrderId(p.getOrderId());
        dto.setOrderNo(p.getOrderNo());
        dto.setAmount(p.getAmount().doubleValue());
        dto.setMethod(p.getMethod());
        dto.setMethodText(getMethodText(p.getMethod()));
        dto.setStatus(p.getStatus());
        dto.setStatusText(getStatusText(p.getStatus()));
        dto.setTransactionNo(p.getTransactionNo());
        dto.setPaidAt(p.getPaidAt());
        dto.setCreatedAt(p.getCreatedAt());
        return dto;
    }

    private RefundRecordDTO toRefundRecordDTO(PaymentRefund r) {
        RefundRecordDTO dto = new RefundRecordDTO();
        dto.setRefundId(r.getRefundId());
        dto.setPaymentId(r.getPaymentId());
        dto.setOrderId(r.getOrderId());
        dto.setRefundNo(r.getRefundNo());
        dto.setTransactionNo(r.getTransactionNo());
        dto.setAmount(r.getAmount().doubleValue());
        dto.setReason(r.getReason());
        dto.setStatus(r.getStatus());
        dto.setCreatedAt(r.getCreatedAt());
        return dto;
    }

    private String getMethodText(String method) {
        if ("alipay".equals(method)) return "支付宝";
        if ("wechat".equals(method)) return "微信支付";
        if ("huawei".equals(method)) return "华为支付";
        return method;
    }

    private String getStatusText(String status) {
        if ("pending".equals(status)) return "待支付";
        if ("processing".equals(status)) return "支付中";
        if ("success".equals(status)) return "已支付";
        if ("failed".equals(status)) return "支付失败";
        if ("closed".equals(status)) return "已关闭";
        if ("refunded".equals(status)) return "已退款";
        return status;
    }
}
