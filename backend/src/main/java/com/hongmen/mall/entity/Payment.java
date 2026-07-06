package com.hongmen.mall.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Entity
@Table(name = "payment")
public class Payment {
    @Id
    @Column(name = "payment_id", length = 64)
    private String paymentId;

    @Column(name = "order_id", nullable = false, length = 64)
    private String orderId;

    @Column(name = "order_no", nullable = false, length = 64)
    private String orderNo;

    @Column(name = "user_id", nullable = false, length = 64)
    private String userId;

    @Column(name = "amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal amount;

    @Column(name = "method", nullable = false, length = 32)
    private String method;

    @Column(name = "status", nullable = false, length = 32)
    private String status;

    @Column(name = "transaction_no", length = 128)
    private String transactionNo;

    @Column(name = "subject", length = 256)
    private String subject;

    @Column(name = "body", length = 512)
    private String body;

    @Column(name = "callback_content", columnDefinition = "TEXT")
    private String callbackContent;

    @Column(name = "paid_at")
    private Long paidAt;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;

    @Column(name = "updated_at", nullable = false)
    private Long updatedAt;
}
