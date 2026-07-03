package com.hongmen.mall.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * 支付流水实体
 */
@Data
@Entity
@Table(name = "payment")
public class Payment {
    @Id
    @Column(name = "payment_id")
    private String paymentId;

    @Column(name = "order_id", nullable = false)
    private String orderId;

    @Column(name = "user_id", nullable = false)
    private String userId;

    @Column(name = "amount", nullable = false)
    private Double amount;

    @Column(name = "method", nullable = false)
    private String method;

    @Column(name = "status", nullable = false)
    private String status;

    @Column(name = "transaction_no")
    private String transactionNo;

    @Column(name = "paid_at")
    private Long paidAt;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;
}
