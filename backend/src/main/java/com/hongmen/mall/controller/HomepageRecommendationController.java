package com.hongmen.mall.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.entity.BrowsingRecord;
import com.hongmen.mall.entity.Product;
import com.hongmen.mall.repository.BrowsingRecordRepository;
import com.hongmen.mall.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class HomepageRecommendationController {

    private final ProductRepository productRepository;
    private final BrowsingRecordRepository browsingRecordRepository;

    @GetMapping("/homepage/recommendations")
    public Result<List<Product>> getHomepageRecommendations(@RequestParam(defaultValue = "default_user") String userId) {
        List<BrowsingRecord> records = browsingRecordRepository.findByUserIdOrderByTimestampDesc(userId);
        if (records.isEmpty()) {
            return Result.success(Collections.emptyList());
        }

        String latestProductId = records.get(0).getProductId();
        Product latestProduct = productRepository.findById(latestProductId).orElse(null);
        if (latestProduct == null) {
            return Result.success(Collections.emptyList());
        }

        String categoryId = latestProduct.getCategoryId();
        Set<String> browsedIds = records.stream()
                .map(BrowsingRecord::getProductId)
                .collect(Collectors.toSet());

        List<Product> result = productRepository.findByCategoryId(categoryId).stream()
                .filter(p -> !p.getProductId().equals(latestProductId))
                .sorted(Comparator.comparingInt(Product::getSalesCount).reversed())
                .limit(30)
                .collect(Collectors.toList());

        log.info("推荐 userId={}, 最近浏览: {} (分类: {}), 推荐 {} 个同类商品",
                userId, latestProduct.getName(), categoryId, result.size());

        return Result.success(result);
    }
}
