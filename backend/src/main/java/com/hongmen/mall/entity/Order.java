package com.hongmen.mall.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * 订单实体
 */
@Data
@Entity
@Table(name = "order_info")
public class Order {
    @Id
    @Column(name = "order_id")
    private String orderId;

    @Column(name = "user_id", nullable = false)
    private String userId;

    @Column(name = "order_no", nullable = false, unique = true)
    private String orderNo;

    @Column(name = "total_amount", nullable = false)
    private Double totalAmount;

    @Column(name = "status", nullable = false)
    private String status;

    @Column(name = "address_id")
    private String addressId;

    @Column(name = "address_snapshot", columnDefinition = "TEXT")
    private String addressSnapshot;

    @Column(name = "remark")
    private String remark;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;

    @Column(name = "updated_at", nullable = false)
    private Long updatedAt;
}
