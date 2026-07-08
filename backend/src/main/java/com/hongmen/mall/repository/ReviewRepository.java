package com.hongmen.mall.repository;

import com.hongmen.mall.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 评价仓库
 */
@Repository
public interface ReviewRepository extends JpaRepository<Review, String> {
    List<Review> findByProductIdOrderByCreatedAtDesc(String productId);
    List<Review> findByUserIdOrderByCreatedAtDesc(String userId);
    List<Review> findByOrderIdOrderByCreatedAtDesc(String orderId);
    boolean existsByUserIdAndProductIdAndOrderId(String userId, String productId, String orderId);
}
