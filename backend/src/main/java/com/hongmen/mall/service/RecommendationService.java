package com.hongmen.mall.service;

import com.hongmen.mall.entity.BrowsingRecord;
import com.hongmen.mall.entity.Product;
import com.hongmen.mall.entity.Recommendation;
import com.hongmen.mall.repository.BrowsingRecordRepository;
import com.hongmen.mall.repository.ProductRepository;
import com.hongmen.mall.repository.RecommendationRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class RecommendationService {

    private static final Logger logger = LoggerFactory.getLogger(RecommendationService.class);

    private static final String TYPE_COLLABORATIVE = "collaborative";
    private static final String TYPE_CONTENT = "content";
    private static final int RECOMMENDATION_LIMIT = 20;

    private final BrowsingRecordRepository browsingRecordRepository;
    private final ProductRepository productRepository;
    private final RecommendationRepository recommendationRepository;

    public RecommendationService(BrowsingRecordRepository browsingRecordRepository,
                                 ProductRepository productRepository,
                                 RecommendationRepository recommendationRepository) {
        this.browsingRecordRepository = browsingRecordRepository;
        this.productRepository = productRepository;
        this.recommendationRepository = recommendationRepository;
    }

    public List<Product> getRecommendations(String userId) {
        List<Recommendation> recommendations = recommendationRepository.findByUserIdOrderByScoreDesc(userId);
        Set<String> productIds = recommendations.stream()
                .limit(RECOMMENDATION_LIMIT)
                .map(Recommendation::getProductId)
                .collect(Collectors.toSet());

        return productRepository.findAllById(productIds).stream()
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }

    public List<Product> getCollaborativeRecommendations(String userId) {
        List<Recommendation> recommendations = recommendationRepository
                .findByUserIdAndTypeOrderByScoreDesc(userId, TYPE_COLLABORATIVE);
        Set<String> productIds = recommendations.stream()
                .limit(RECOMMENDATION_LIMIT)
                .map(Recommendation::getProductId)
                .collect(Collectors.toSet());

        return productRepository.findAllById(productIds).stream()
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }

    public List<Product> getContentRecommendations(String userId) {
        List<Recommendation> recommendations = recommendationRepository
                .findByUserIdAndTypeOrderByScoreDesc(userId, TYPE_CONTENT);
        Set<String> productIds = recommendations.stream()
                .limit(RECOMMENDATION_LIMIT)
                .map(Recommendation::getProductId)
                .collect(Collectors.toSet());

        return productRepository.findAllById(productIds).stream()
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }

    public List<Recommendation> getRecommendationEntities(String userId) {
        return recommendationRepository.findByUserIdOrderByScoreDesc(userId);
    }

    public List<Recommendation> getCollaborativeRecommendationEntities(String userId) {
        return recommendationRepository.findByUserIdAndTypeOrderByScoreDesc(userId, TYPE_COLLABORATIVE);
    }

    public List<Recommendation> getContentRecommendationEntities(String userId) {
        return recommendationRepository.findByUserIdAndTypeOrderByScoreDesc(userId, TYPE_CONTENT);
    }

    public List<Product> getSimilarProductsByLatestBrowse(String userId) {
        List<BrowsingRecord> latestRecords = browsingRecordRepository.findByUserIdOrderByTimestampDesc(userId);
        if (latestRecords.isEmpty()) {
            return getHotProductRecommendations(TYPE_CONTENT).stream()
                    .map(r -> productRepository.findById(r.getProductId()).orElse(null))
                    .filter(Objects::nonNull)
                    .collect(Collectors.toList());
        }

        String latestProductId = latestRecords.get(0).getProductId();
        Product latestProduct = productRepository.findById(latestProductId).orElse(null);
        if (latestProduct == null) {
            return getHotProductRecommendations(TYPE_CONTENT).stream()
                    .map(r -> productRepository.findById(r.getProductId()).orElse(null))
                    .filter(Objects::nonNull)
                    .collect(Collectors.toList());
        }

        String categoryId = latestProduct.getCategoryId();
        String brand = latestProduct.getBrand();

        List<Product> similarProducts = productRepository.findByCategoryId(categoryId).stream()
                .filter(p -> !p.getProductId().equals(latestProductId))
                .filter(p -> p.getBrand() != null && p.getBrand().equals(brand))
                .sorted((a, b) -> Double.compare(b.getRating(), a.getRating()))
                .limit(6)
                .collect(Collectors.toList());

        if (similarProducts.size() < 6) {
            List<Product> moreProducts = productRepository.findByCategoryId(categoryId).stream()
                    .filter(p -> !p.getProductId().equals(latestProductId))
                    .filter(p -> !similarProducts.contains(p))
                    .sorted((a, b) -> Double.compare(b.getRating(), a.getRating()))
                    .limit(6 - similarProducts.size())
                    .collect(Collectors.toList());
            similarProducts.addAll(moreProducts);
        }

        return similarProducts;
    }

    @Transactional
    public void refreshAllRecommendations() {
        logger.info("Starting to refresh all recommendations...");
        
        List<String> allUsers = browsingRecordRepository.findAll().stream()
                .map(BrowsingRecord::getUserId)
                .distinct()
                .collect(Collectors.toList());

        for (String userId : allUsers) {
            try {
                refreshRecommendationsForUser(userId);
            } catch (Exception e) {
                logger.error("Failed to refresh recommendations for user {}: {}", userId, e.getMessage());
            }
        }

        logger.info("Finished refreshing recommendations for {} users", allUsers.size());
    }

    @Transactional
    public void refreshRecommendationsForUser(String userId) {
        List<Recommendation> collaborativeRecs = computeCollaborativeFiltering(userId);
        List<Recommendation> contentRecs = computeContentBased(userId);

        recommendationRepository.deleteByUserId(userId);

        int rank = 1;
        for (Recommendation rec : collaborativeRecs) {
            rec.setRecRank(rank++);
        }
        rank = 1;
        for (Recommendation rec : contentRecs) {
            rec.setRecRank(rank++);
        }

        recommendationRepository.saveAll(collaborativeRecs);
        recommendationRepository.saveAll(contentRecs);

        logger.info("Refreshed recommendations for user {}: {} collaborative, {} content",
                userId, collaborativeRecs.size(), contentRecs.size());
    }

    private List<Recommendation> computeCollaborativeFiltering(String userId) {
        Map<String, Double> scores = new HashMap<>();

        List<BrowsingRecord> userRecords = browsingRecordRepository.findByUserIdOrderByTimestampDesc(userId);
        if (userRecords.isEmpty()) {
            return getHotProductRecommendations(TYPE_COLLABORATIVE);
        }

        Set<String> userProducts = userRecords.stream()
                .map(BrowsingRecord::getProductId)
                .collect(Collectors.toSet());

        List<String> allUsers = browsingRecordRepository.findAll().stream()
                .map(BrowsingRecord::getUserId)
                .distinct()
                .filter(u -> !u.equals(userId))
                .collect(Collectors.toList());

        Map<String, Double> userSimilarities = new HashMap<>();
        Map<String, Set<String>> userProductMap = new HashMap<>();

        for (String otherUser : allUsers) {
            List<BrowsingRecord> otherRecords = browsingRecordRepository.findByUserIdOrderByTimestampDesc(otherUser);
            Set<String> otherProducts = otherRecords.stream()
                    .map(BrowsingRecord::getProductId)
                    .collect(Collectors.toSet());

            userProductMap.put(otherUser, otherProducts);

            double similarity = cosineSimilarity(userProducts, otherProducts);
            userSimilarities.put(otherUser, similarity);
        }

        List<Map.Entry<String, Double>> sortedSimilarities = userSimilarities.entrySet().stream()
                .filter(e -> e.getValue() > 0.1)
                .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
                .limit(20)
                .collect(Collectors.toList());

        for (Map.Entry<String, Double> entry : sortedSimilarities) {
            String similarUser = entry.getKey();
            double similarity = entry.getValue();

            for (String productId : userProductMap.get(similarUser)) {
                if (!userProducts.contains(productId)) {
                    scores.merge(productId, similarity, Double::sum);
                }
            }
        }

        Map<String, Integer> productPopularity = computeProductPopularity();
        for (String productId : scores.keySet()) {
            double popularityBoost = Math.log1p(productPopularity.getOrDefault(productId, 0));
            scores.put(productId, scores.get(productId) * (1 + popularityBoost * 0.1));
        }

        List<Recommendation> recommendations = scores.entrySet().stream()
                .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
                .limit(RECOMMENDATION_LIMIT)
                .map(entry -> createRecommendation(userId, entry.getKey(), entry.getValue(), TYPE_COLLABORATIVE))
                .collect(Collectors.toList());

        if (recommendations.isEmpty()) {
            return getHotProductRecommendations(TYPE_COLLABORATIVE);
        }

        return recommendations;
    }

    private List<Recommendation> computeContentBased(String userId) {
        Map<String, Double> scores = new HashMap<>();

        List<BrowsingRecord> userRecords = browsingRecordRepository.findByUserIdOrderByTimestampDesc(userId);
        if (userRecords.isEmpty()) {
            return getHotProductRecommendations(TYPE_CONTENT);
        }

        Map<String, Integer> categoryCount = new HashMap<>();
        Map<String, Integer> brandCount = new HashMap<>();
        Map<String, Integer> productCount = new HashMap<>();

        for (BrowsingRecord record : userRecords) {
            Product product = productRepository.findById(record.getProductId()).orElse(null);
            if (product != null) {
                categoryCount.merge(product.getCategoryId(), 1, Integer::sum);
                if (product.getBrand() != null) {
                    brandCount.merge(product.getBrand(), 1, Integer::sum);
                }
                productCount.merge(record.getProductId(), record.getBrowseCount(), Integer::sum);
            }
        }

        Set<String> userProducts = userRecords.stream()
                .map(BrowsingRecord::getProductId)
                .collect(Collectors.toSet());

        List<Product> allProducts = productRepository.findAll();

        for (Product product : allProducts) {
            if (userProducts.contains(product.getProductId())) {
                continue;
            }

            double score = 0;

            if (categoryCount.containsKey(product.getCategoryId())) {
                score += categoryCount.get(product.getCategoryId()) * 0.5;
            }

            if (product.getBrand() != null && brandCount.containsKey(product.getBrand())) {
                score += brandCount.get(product.getBrand()) * 0.3;
            }

            score += product.getRating() * 0.15;
            score += Math.log1p(product.getSalesCount()) * 0.05;

            if (score > 0) {
                scores.put(product.getProductId(), score);
            }
        }

        List<Recommendation> recommendations = scores.entrySet().stream()
                .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
                .limit(RECOMMENDATION_LIMIT)
                .map(entry -> createRecommendation(userId, entry.getKey(), entry.getValue(), TYPE_CONTENT))
                .collect(Collectors.toList());

        if (recommendations.isEmpty()) {
            return getHotProductRecommendations(TYPE_CONTENT);
        }

        return recommendations;
    }

    private List<Recommendation> getHotProductRecommendations(String type) {
        List<Product> hotProducts = productRepository.findAll().stream()
                .sorted((a, b) -> Integer.compare(b.getSalesCount(), a.getSalesCount()))
                .limit(RECOMMENDATION_LIMIT)
                .collect(Collectors.toList());

        return hotProducts.stream()
                .map(product -> createRecommendation("default", product.getProductId(),
                        (double) product.getSalesCount(), type))
                .collect(Collectors.toList());
    }

    private double cosineSimilarity(Set<String> set1, Set<String> set2) {
        if (set1.isEmpty() || set2.isEmpty()) {
            return 0;
        }

        Set<String> intersection = new HashSet<>(set1);
        intersection.retainAll(set2);

        return (double) intersection.size() / Math.sqrt(set1.size() * set2.size());
    }

    private Map<String, Integer> computeProductPopularity() {
        Map<String, Integer> popularity = new HashMap<>();
        List<BrowsingRecord> allRecords = browsingRecordRepository.findAll();

        for (BrowsingRecord record : allRecords) {
            popularity.merge(record.getProductId(), record.getBrowseCount(), Integer::sum);
        }

        return popularity;
    }

    private Recommendation createRecommendation(String userId, String productId, Double score, String type) {
        Recommendation rec = new Recommendation();
        rec.setUserId(userId);
        rec.setProductId(productId);
        rec.setScore(score);
        rec.setType(type);
        rec.setUpdatedAt(System.currentTimeMillis());
        return rec;
    }
}