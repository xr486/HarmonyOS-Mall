package com.hongmen.mall.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * 购物车实体
 */
@Data
@Entity
@Table(name = "cart_item")
public class CartItem {
    @Id
    @Column(name = "cart_id")
    private String cartId;

    @Column(name = "user_id", nullable = false)
    private String userId;

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

    @Column(name = "checked")
    private Boolean checked;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;

    @Column(name = "updated_at", nullable = false)
    private Long updatedAt;
}
