package com.hongmen.mall.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * 商品评价实体
 */
@Data
@Entity
@Table(name = "review")
public class Review {
    @Id
    @Column(name = "review_id")
    private String reviewId;

    @Column(name = "product_id", nullable = false)
    private String productId;

    @Column(name = "user_id", nullable = false)
    private String userId;

    @Column(name = "user_name")
    private String userName;

    @Column(name = "rating", nullable = false)
    private Integer rating;

    @Column(name = "content", columnDefinition = "TEXT")
    private String content;

    @Column(name = "images", columnDefinition = "TEXT")
    private String images;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;
}
