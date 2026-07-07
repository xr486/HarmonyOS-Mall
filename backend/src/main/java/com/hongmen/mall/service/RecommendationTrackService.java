package com.hongmen.mall.service;

import com.hongmen.mall.entity.RecommendationTrack;
import com.hongmen.mall.repository.RecommendationTrackRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class RecommendationTrackService {

    private final RecommendationTrackRepository trackRepository;

    @Transactional
    public void trackClick(String userId, String productId, String recType, Integer rankPosition, String sourcePage) {
        RecommendationTrack track = new RecommendationTrack();
        track.setTrackId(UUID.randomUUID().toString().replace("-", ""));
        track.setUserId(userId);
        track.setProductId(productId);
        track.setRecType(recType);
        track.setAction("click");
        track.setRankPosition(rankPosition);
        track.setSourcePage(sourcePage);
        track.setCreatedAt(System.currentTimeMillis());
        trackRepository.save(track);
        log.debug("推荐点击追踪: productId={}, recType={}, position={}", productId, recType, rankPosition);
    }

    @Transactional
    public void trackConversion(String userId, String productId, String recType, Integer rankPosition, String sourcePage) {
        RecommendationTrack track = new RecommendationTrack();
        track.setTrackId(UUID.randomUUID().toString().replace("-", ""));
        track.setUserId(userId);
        track.setProductId(productId);
        track.setRecType(recType);
        track.setAction("conversion");
        track.setRankPosition(rankPosition);
        track.setSourcePage(sourcePage);
        track.setCreatedAt(System.currentTimeMillis());
        trackRepository.save(track);
        log.debug("推荐转化追踪: productId={}, recType={}", productId, recType);
    }

    public Map<String, Object> getRecommendationStats() {
        Map<String, Object> stats = new LinkedHashMap<>();

        List<Object[]> topClicked = trackRepository.findTopClickedProducts(20);
        stats.put("topClickedProducts", topClicked.stream()
                .map(row -> {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("productId", row[0]);
                    item.put("clickCount", row[1]);
                    return item;
                }).collect(Collectors.toList()));

        List<Object[]> topConverted = trackRepository.findTopConvertedProducts(20);
        stats.put("topConvertedProducts", topConverted.stream()
                .map(row -> {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("productId", row[0]);
                    item.put("conversionCount", row[1]);
                    return item;
                }).collect(Collectors.toList()));

        Map<String, Long> recTypeClickCount = new LinkedHashMap<>();
        List<Object[]> recTypeClicks = trackRepository.countByActionGroupByRecType("click");
        for (Object[] row : recTypeClicks) {
            recTypeClickCount.put((String) row[0], (Long) row[1]);
        }
        stats.put("recTypeClickCount", recTypeClickCount);

        Map<String, Long> recTypeConvCount = new LinkedHashMap<>();
        List<Object[]> recTypeConvs = trackRepository.countByActionGroupByRecType("conversion");
        for (Object[] row : recTypeConvs) {
            recTypeConvCount.put((String) row[0], (Long) row[1]);
        }
        stats.put("recTypeConversionCount", recTypeConvCount);

        Map<String, Double> conversionRates = new LinkedHashMap<>();
        for (String recType : recTypeClickCount.keySet()) {
            long clicks = recTypeClickCount.getOrDefault(recType, 0L);
            long conversions = recTypeConvCount.getOrDefault(recType, 0L);
            double rate = clicks > 0 ? (double) conversions / clicks * 100 : 0;
            conversionRates.put(recType, Math.round(rate * 100.0) / 100.0);
        }
        stats.put("conversionRates", conversionRates);

        return stats;
    }
}
