package com.hongmen.mall.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "recommendation", indexes = {
        @Index(name = "idx_user_id", columnList = "user_id"),
        @Index(name = "idx_type", columnList = "type")
})
public class Recommendation {

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", length = 64, nullable = false)
    private String userId;

    @Column(name = "product_id", length = 64, nullable = false)
    private String productId;

    @Column(name = "score", nullable = false)
    private Double score;

    @Column(name = "type", length = 32, nullable = false)
    private String type;

    @Column(name = "rec_rank", nullable = false)
    private Integer recRank;

    @Column(name = "updated_at", nullable = false)
    private Long updatedAt;
}