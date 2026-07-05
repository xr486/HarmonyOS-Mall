package com.hongmen.mall.repository;

import com.hongmen.mall.entity.BrowsingRecord;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;

@Repository
public interface BrowsingRecordRepository extends JpaRepository<BrowsingRecord, String> {

    List<BrowsingRecord> findByUserIdOrderByTimestampDesc(String userId);

    Page<BrowsingRecord> findByUserIdOrderByTimestampDesc(String userId, Pageable pageable);

    BrowsingRecord findByRecordId(String recordId);

    void deleteByRecordId(String recordId);

    void deleteByUserId(String userId);

    long countByUserId(String userId);

    @Query("SELECT b FROM BrowsingRecord b WHERE " +
           "(:userId IS NULL OR b.userId = :userId) AND " +
           "(:productName IS NULL OR b.productName LIKE %:productName%) AND " +
           "(:startTime IS NULL OR b.timestamp >= :startTime) AND " +
           "(:endTime IS NULL OR b.timestamp <= :endTime) " +
           "ORDER BY b.timestamp DESC")
    Page<BrowsingRecord> queryWithConditions(
            @Param("userId") String userId,
            @Param("productName") String productName,
            @Param("startTime") Date startTime,
            @Param("endTime") Date endTime,
            Pageable pageable);
}