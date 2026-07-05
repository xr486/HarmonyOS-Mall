package com.hongmen.mall.repository;

import com.hongmen.mall.entity.Recommendation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RecommendationRepository extends JpaRepository<Recommendation, Long> {

    List<Recommendation> findByUserIdAndTypeOrderByScoreDesc(String userId, String type);

    List<Recommendation> findByUserIdOrderByScoreDesc(String userId);

    void deleteByUserId(String userId);

    void deleteByUserIdAndType(String userId, String type);

    long countByUserId(String userId);
}