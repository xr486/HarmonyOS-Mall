
package com.hongmen.mall.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * 用户实体
 */
@Data
@Entity
@Table(name = "user")
public class User {
    @Id
    @Column(name = "user_id")
    private String userId;

    @Column(name = "phone", unique = true, nullable = false)
    private String phone;

    @Column(name = "nickname")
    private String nickname;

    @Column(name = "avatar")
    private String avatar;

    @Column(name = "huawei_account")
    private String huaweiAccount;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;

    @Column(name = "updated_at", nullable = false)
    private Long updatedAt;
}
