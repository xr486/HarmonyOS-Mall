
package com.hongmen.mall.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * 收货地址实体
 */
@Data
@Entity
@Table(name = "address")
public class Address {
    @Id
    @Column(name = "address_id")
    private String addressId;

    @Column(name = "user_id", nullable = false)
    private String userId;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "phone", nullable = false)
    private String phone;

    @Column(name = "province", nullable = false)
    private String province;

    @Column(name = "city", nullable = false)
    private String city;

    @Column(name = "district", nullable = false)
    private String district;

    @Column(name = "detail", nullable = false)
    private String detail;

    @Column(name = "is_default", nullable = false)
    private Boolean isDefault;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;

    @Column(name = "updated_at", nullable = false)
    private Long updatedAt;
}
