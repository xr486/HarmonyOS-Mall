
package com.hongmen.mall.repository;

import com.hongmen.mall.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 分类仓库
 */
@Repository
public interface CategoryRepository extends JpaRepository<Category, String> {
    List<Category> findByParentIdOrderBySortOrder(String parentId);
    List<Category> findByParentIdIsNullOrderBySortOrder();
}
