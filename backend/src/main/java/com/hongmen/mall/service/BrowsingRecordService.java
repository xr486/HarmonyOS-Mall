package com.hongmen.mall.service;

import com.hongmen.mall.entity.BrowsingRecord;
import com.hongmen.mall.repository.BrowsingRecordRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class BrowsingRecordService {

    private static final Logger logger = LoggerFactory.getLogger(BrowsingRecordService.class);

    private final BrowsingRecordRepository repository;

    public BrowsingRecordService(BrowsingRecordRepository repository) {
        this.repository = repository;
    }

    public void upsert(BrowsingRecord record) {
        repository.save(record);
        logger.info("Upserted browsing record: {}", record.getRecordId());
    }

    public void recordBrowsing(String userId, String productId, String productName, 
                               String productImage, Double productPrice) {
        BrowsingRecord existing = repository.findByRecordId(userId + ":" + productId);
        if (existing != null) {
            existing.setBrowseCount(existing.getBrowseCount() + 1);
            existing.setTimestamp(new Date());
            if (productName != null) existing.setProductName(productName);
            if (productImage != null) existing.setProductImage(productImage);
            if (productPrice != null) existing.setProductPrice(productPrice);
            repository.save(existing);
            logger.info("Updated browsing record for user {} product {}", userId, productId);
        } else {
            BrowsingRecord record = new BrowsingRecord();
            record.setRecordId(userId + ":" + productId);
            record.setUserId(userId);
            record.setProductId(productId);
            record.setProductName(productName);
            record.setProductImage(productImage);
            record.setProductPrice(productPrice);
            record.setBrowseCount(1);
            record.setTimestamp(new Date());
            repository.save(record);
            logger.info("Created new browsing record for user {} product {}", userId, productId);
        }
    }

    public void upsertBatch(List<BrowsingRecord> records) {
        repository.saveAll(records);
        logger.info("Batch upserted {} browsing records", records.size());
    }

    public List<BrowsingRecord> queryByUserId(String userId) {
        return repository.findByUserIdOrderByTimestampDesc(userId);
    }

    public Map<String, Object> queryByUserIdWithPage(String userId, int pageNum, int pageSize) {
        Pageable pageable = PageRequest.of(pageNum - 1, pageSize, Sort.by(Sort.Direction.DESC, "timestamp"));
        Page<BrowsingRecord> page = repository.findByUserIdOrderByTimestampDesc(userId, pageable);

        Map<String, Object> result = new HashMap<>();
        result.put("records", page.getContent());
        result.put("total", page.getTotalElements());
        result.put("pageNum", pageNum);
        result.put("pageSize", pageSize);
        result.put("totalPages", page.getTotalPages());

        return result;
    }

    public void deleteById(String recordId) {
        repository.deleteByRecordId(recordId);
        logger.info("Deleted browsing record: {}", recordId);
    }

    public void deleteByUserId(String userId) {
        repository.deleteByUserId(userId);
        logger.info("Deleted all browsing records for user: {}", userId);
    }

    public Map<String, Object> queryWithConditions(String userId, String productName,
                                                   Long startTime, Long endTime,
                                                   int pageNum, int pageSize) {
        Date startDate = startTime != null ? new Date(startTime) : null;
        Date endDate = endTime != null ? new Date(endTime) : null;

        Pageable pageable = PageRequest.of(pageNum - 1, pageSize);
        Page<BrowsingRecord> page = repository.queryWithConditions(userId, productName, startDate, endDate, pageable);

        Map<String, Object> result = new HashMap<>();
        result.put("records", page.getContent());
        result.put("total", page.getTotalElements());
        result.put("pageNum", pageNum);
        result.put("pageSize", pageSize);
        result.put("totalPages", page.getTotalPages());

        return result;
    }
}