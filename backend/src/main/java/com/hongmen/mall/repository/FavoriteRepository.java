package com.hongmen.mall.repository;

import com.hongmen.mall.entity.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 收藏仓库
 */
@Repository
public interface FavoriteRepository extends JpaRepository<Favorite, String> {
    List<Favorite> findByUserIdOrderByCreatedAtDesc(String userId);
    Optional<Favorite> findByUserIdAndProductId(String userId, String productId);
    boolean existsByUserIdAndProductId(String userId, String productId);
    void deleteByUserIdAndProductId(String userId, String productId);
}
