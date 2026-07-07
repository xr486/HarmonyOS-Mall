package com.hongmen.mall.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "recommendation_track")
@Data
public class RecommendationTrack {

    @Id
    @Column(name = "track_id", length = 32)
    private String trackId;

    @Column(name = "user_id", length = 32)
    private String userId;

    @Column(name = "product_id", length = 32)
    private String productId;

    @Column(name = "rec_type", length = 20)
    private String recType;

    @Column(name = "action", length = 20)
    private String action;

    @Column(name = "rank_position")
    private Integer rankPosition;

    @Column(name = "source_page", length = 50)
    private String sourcePage;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;
}
