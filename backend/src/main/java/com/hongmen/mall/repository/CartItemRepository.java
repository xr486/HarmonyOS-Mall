package com.hongmen.mall.repository;

import com.hongmen.mall.entity.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 购物车仓库
 */
@Repository
public interface CartItemRepository extends JpaRepository<CartItem, String> {
    List<CartItem> findByUserId(String userId);
    Optional<CartItem> findByUserIdAndProductIdAndSpecs(String userId, String productId, String specs);
    void deleteByUserId(String userId);
}
