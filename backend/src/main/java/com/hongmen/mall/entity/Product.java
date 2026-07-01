
package com.hongmen.mall.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * 商品实体
 */
@Data
@Entity
@Table(name = "product")
public class Product {
    @Id
    @Column(name = "product_id")
    private String productId;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "price", nullable = false)
    private Long price;

    @Column(name = "original_price")
    private Long originalPrice;

    @Column(name = "stock", nullable = false)
    private Integer stock;

    @Column(name = "images", columnDefinition = "TEXT")
    private String images;

    @Column(name = "brand")
    private String brand;

    @Column(name = "category_id", nullable = false)
    private String categoryId;

    @Column(name = "rating", nullable = false)
    private Double rating;

    @Column(name = "sales_count", nullable = false)
    private Integer salesCount;

    @Column(name = "specs", columnDefinition = "TEXT")
    private String specs;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "longitude")
    private Double longitude;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;
}
