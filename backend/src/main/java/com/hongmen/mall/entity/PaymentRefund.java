package com.hongmen.mall.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "payment_refund")
@Data
public class PaymentRefund {

    @Id
    @Column(name = "refund_id", length = 32)
    private String refundId;

    @Column(name = "payment_id", length = 32, nullable = false)
    private String paymentId;

    @Column(name = "order_id", length = 32, nullable = false)
    private String orderId;

    @Column(name = "transaction_no", length = 64)
    private String transactionNo;

    @Column(name = "refund_no", length = 64, unique = true)
    private String refundNo;

    @Column(name = "amount", precision = 10, scale = 2, nullable = false)
    private java.math.BigDecimal amount;

    @Column(name = "reason", length = 500)
    private String reason;

    @Column(name = "status", length = 20, nullable = false)
    private String status;

    @Column(name = "callback_content", columnDefinition = "TEXT")
    private String callbackContent;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;

    @Column(name = "updated_at", nullable = false)
    private Long updatedAt;
}
