
package com.hongmen.mall.repository;

import com.hongmen.mall.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 商品仓库
 */
@Repository
public interface ProductRepository extends JpaRepository<Product, String> {
    List<Product> findByCategoryId(String categoryId);
    List<Product> findByNameContainingOrDescriptionContainingOrBrandContainingOrderBySalesCountDesc(
        String nameKeyword, String descKeyword, String brandKeyword);
}
