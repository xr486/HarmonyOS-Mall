package com.hongmen.mall.repository;

import com.hongmen.mall.entity.RecommendationTrack;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RecommendationTrackRepository extends JpaRepository<RecommendationTrack, String> {

    List<RecommendationTrack> findByProductIdAndAction(String productId, String action);

    @Query("SELECT rt.productId, COUNT(rt) FROM RecommendationTrack rt WHERE rt.action = ?1 GROUP BY rt.productId ORDER BY COUNT(rt) DESC")
    List<Object[]> countByActionGroupByProduct(String action);

    @Query("SELECT rt.productId, COUNT(rt) as cnt FROM RecommendationTrack rt WHERE rt.action = ?1 GROUP BY rt.productId")
    List<Object[]> findAllByActionGroupByProduct(String action);

    @Query("SELECT rt.productId, rt.action, COUNT(rt) FROM RecommendationTrack rt GROUP BY rt.productId, rt.action")
    List<Object[]> countByProductIdAndAction();

    List<RecommendationTrack> findByUserIdAndAction(String userId, String action);

    @Query("SELECT rt.recType, COUNT(rt) FROM RecommendationTrack rt WHERE rt.action = ?1 GROUP BY rt.recType")
    List<Object[]> countByActionGroupByRecType(String action);

    @Query(value = "SELECT product_id, COUNT(*) as click_count FROM recommendation_track WHERE action = 'click' GROUP BY product_id ORDER BY click_count DESC LIMIT ?1", nativeQuery = true)
    List<Object[]> findTopClickedProducts(int limit);

    @Query(value = "SELECT product_id, COUNT(*) as conv_count FROM recommendation_track WHERE action = 'conversion' GROUP BY product_id ORDER BY conv_count DESC LIMIT ?1", nativeQuery = true)
    List<Object[]> findTopConvertedProducts(int limit);
}
