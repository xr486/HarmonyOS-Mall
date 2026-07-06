package com.hongmen.mall.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * 商品收藏实体
 */
@Data
@Entity
@Table(name = "favorite", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"user_id", "product_id"})
})
public class Favorite {
    @Id
    @Column(name = "favorite_id")
    private String favoriteId;

    @Column(name = "user_id", nullable = false)
    private String userId;

    @Column(name = "product_id", nullable = false)
    private String productId;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;
}
