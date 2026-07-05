package com.hongmen.mall.controller;

import com.hongmen.mall.entity.BrowsingRecord;
import com.hongmen.mall.service.BrowsingRecordService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/browsing-record")
public class BrowsingRecordController {

    private final BrowsingRecordService browsingRecordService;

    public BrowsingRecordController(BrowsingRecordService browsingRecordService) {
        this.browsingRecordService = browsingRecordService;
    }

    @PostMapping("/test-save")
    public ResponseEntity<String> testSave() {
        try {
            BrowsingRecord record = new BrowsingRecord();
            record.setRecordId(UUID.randomUUID().toString());
            record.setUserId("test_user_001");
            record.setProductId("product_001");
            record.setProductName("测试商品");
            record.setProductImage("https://example.com/image.jpg");
            record.setProductPrice(99.99);
            record.setBrowseCount(1);
            record.setTimestamp(new Date());

            browsingRecordService.upsert(record);
            return ResponseEntity.ok("保存成功！recordId: " + record.getRecordId());
        } catch (Exception e) {
            return ResponseEntity.status(500).body("保存失败: " + e.getMessage());
        }
    }

    @GetMapping("/test-query")
    public ResponseEntity<?> testQuery() {
        try {
            List<BrowsingRecord> records = browsingRecordService.queryByUserId("test_user_001");
            return ResponseEntity.ok(records);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("查询失败: " + e.getMessage());
        }
    }

    @GetMapping("/test-query-page")
    public ResponseEntity<?> testQueryPage(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize) {
        try {
            Map<String, Object> result = browsingRecordService.queryByUserIdWithPage("test_user_001", pageNum, pageSize);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("查询失败: " + e.getMessage());
        }
    }

    @DeleteMapping("/test-delete/{recordId}")
    public ResponseEntity<String> testDelete(@PathVariable String recordId) {
        try {
            browsingRecordService.deleteById(recordId);
            return ResponseEntity.ok("删除成功！");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("删除失败: " + e.getMessage());
        }
    }

    @DeleteMapping("/test-clear")
    public ResponseEntity<String> testClear(@RequestParam String userId) {
        try {
            browsingRecordService.deleteByUserId(userId);
            return ResponseEntity.ok("清空成功！");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("清空失败: " + e.getMessage());
        }
    }

    @PostMapping("/test-conditions")
    public ResponseEntity<?> testConditions(
            @RequestParam(required = false) String userId,
            @RequestParam(required = false) String productName,
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize) {
        try {
            Map<String, Object> result = browsingRecordService.queryWithConditions(
                    userId, productName, null, null, pageNum, pageSize);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("查询失败: " + e.getMessage());
        }
    }
}