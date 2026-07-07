package com.hongmen.mall.service;

import com.hongmen.mall.entity.Product;
import com.hongmen.mall.entity.BrowsingRecord;
import com.hongmen.mall.repository.BrowsingRecordRepository;
import com.hongmen.mall.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class HomepageService {

    private final ProductRepository productRepository;
    private final BrowsingRecordRepository browsingRecordRepository;
    private final RecommendationService recommendationService;

    private static final int MAX_RESULT = 30;
    private static final int HOT_FALLBACK_COUNT = 20;

    public List<Product> getMixedRecommendations(String userId) {
        List<BrowsingRecord> latestRecords = browsingRecordRepository.findByUserIdOrderByTimestampDesc(userId);
        if (latestRecords.isEmpty()) {
            return getHotProducts();
        }

        String latestProductId = latestRecords.get(0).getProductId();
        Product latestProduct = productRepository.findById(latestProductId).orElse(null);
        if (latestProduct == null) {
            return getHotProducts();
        }

        String categoryId = latestProduct.getCategoryId();
        Set<String> browsedIds = latestRecords.stream()
                .map(BrowsingRecord::getProductId)
                .collect(Collectors.toSet());

        Set<String> seenIds = new LinkedHashSet<>();
        List<Product> result = new ArrayList<>();

        try {
            List<Product> similarRecs = recommendationService.getSimilarProductsByLatestBrowse(userId);
            if (similarRecs != null) {
                for (Product p : similarRecs) {
                    if (seenIds.add(p.getProductId())) {
                        result.add(p);
                    }
                }
            }
        } catch (Exception e) {
            log.debug("浏览推荐获取失败: {}", e.getMessage());
        }

        if (result.size() < MAX_RESULT) {
            List<Product> sameCategoryRest = productRepository.findByCategoryId(categoryId).stream()
                    .filter(p -> !p.getProductId().equals(latestProductId))
                    .filter(p -> !browsedIds.contains(p.getProductId()))
                    .filter(p -> seenIds.add(p.getProductId()))
                    .sorted(Comparator.comparing(Product::getRating, Comparator.nullsLast(Comparator.reverseOrder()))
                            .thenComparing(Product::getSalesCount, Comparator.nullsLast(Comparator.reverseOrder())))
                    .limit(MAX_RESULT - result.size())
                    .collect(Collectors.toList());
            result.addAll(sameCategoryRest);
        }

        return result;
    }

    public List<Product> getHotProducts() {
        return productRepository.findAll().stream()
                .sorted(Comparator.comparingInt(Product::getSalesCount).reversed())
                .limit(HOT_FALLBACK_COUNT)
                .collect(Collectors.toList());
    }
}
