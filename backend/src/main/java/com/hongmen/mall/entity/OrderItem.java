package com.hongmen.mall.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * 订单明细实体
 */
@Data
@Entity
@Table(name = "order_item")
public class OrderItem {
    @Id
    @Column(name = "item_id")
    private String itemId;

    @Column(name = "order_id", nullable = false)
    private String orderId;

    @Column(name = "product_id", nullable = false)
    private String productId;

    @Column(name = "product_name")
    private String productName;

    @Column(name = "product_image")
    private String productImage;

    @Column(name = "price", nullable = false)
    private Double price;

    @Column(name = "quantity", nullable = false)
    private Integer quantity;

    @Column(name = "specs")
    private String specs;
}
