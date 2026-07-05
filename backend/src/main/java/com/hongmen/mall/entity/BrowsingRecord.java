package com.hongmen.mall.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.util.Date;

@Data
@Entity
@Table(name = "browsing_record", indexes = {
        @Index(name = "idx_user_id", columnList = "user_id"),
        @Index(name = "idx_timestamp", columnList = "timestamp")
})
public class BrowsingRecord {

    @Id
    @Column(name = "record_id", length = 64)
    private String recordId;

    @Column(name = "user_id", length = 64, nullable = false)
    private String userId;

    @Column(name = "product_id", length = 64, nullable = false)
    private String productId;

    @Column(name = "product_name", length = 255)
    private String productName;

    @Column(name = "product_image", length = 512)
    private String productImage;

    @Column(name = "product_price")
    private Double productPrice;

    @Column(name = "browse_count")
    private Integer browseCount;

    @Column(name = "timestamp", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date timestamp;
}