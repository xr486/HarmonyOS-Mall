
package com.hongmen.mall.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * 分类实体
 */
@Data
@Entity
@Table(name = "category")
public class Category {
    @Id
    @Column(name = "category_id")
    private String categoryId;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "icon")
    private String icon;

    @Column(name = "parent_id")
    private String parentId;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;

    @Column(name = "updated_at", nullable = false)
    private Long updatedAt;
}
