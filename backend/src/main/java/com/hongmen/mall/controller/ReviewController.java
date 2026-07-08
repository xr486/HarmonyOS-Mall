package com.hongmen.mall.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.entity.Review;
import com.hongmen.mall.entity.Product;
import com.hongmen.mall.repository.ReviewRepository;
import com.hongmen.mall.repository.ProductRepository;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 商品评价控制器
 */
@RestController
@RequestMapping("/api/v1/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewRepository reviewRepository;
    private final ProductRepository productRepository;

    private String getUserId(HttpServletRequest request) {
        return (String) request.getAttribute("userId");
    }

    /**
     * 获取商品的评价列表
     */
    @GetMapping("/product/{productId}")
    public Result<List<Map<String, Object>>> getProductReviews(@PathVariable String productId) {
        List<Review> reviews = reviewRepository.findByProductIdOrderByCreatedAtDesc(productId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (Review r : reviews) {
            result.add(buildReviewMap(r));
        }
        return Result.success(result);
    }

    /**
     * 获取用户对某笔订单的评价
     */
    @GetMapping("/order/{orderId}")
    public Result<List<Map<String, Object>>> getOrderReviews(@PathVariable String orderId,
                                                             HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");

        List<Review> reviews = reviewRepository.findByOrderIdOrderByCreatedAtDesc(orderId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (Review r : reviews) {
            result.add(buildReviewMap(r));
        }
        return Result.success(result);
    }

    /**
     * 检查用户是否已评价过某商品（在特定订单中）
     */
    @GetMapping("/check")
    public Result<Map<String, Object>> checkReviewed(@RequestParam String productId,
                                                     @RequestParam(required = false) String orderId,
                                                     HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.success(Map.of("reviewed", false));

        boolean reviewed = reviewRepository.existsByUserIdAndProductIdAndOrderId(userId, productId,
                orderId != null ? orderId : "");
        return Result.success(Map.of("reviewed", reviewed));
    }

    /**
     * 提交评价
     */
    @PostMapping
    @Transactional
    public Result<Map<String, Object>> createReview(@RequestBody Map<String, Object> body,
                                                    HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");

        String productId = (String) body.get("productId");
        Integer rating = body.get("rating") != null ? ((Number) body.get("rating")).intValue() : 5;
        String content = (String) body.getOrDefault("content", "");
        String userName = (String) body.getOrDefault("userName", "匿名用户");
        String orderId = (String) body.get("orderId");
        String orderItemId = (String) body.get("orderItemId");

        if (productId == null || productId.isEmpty()) {
            return Result.error(400, "商品ID不能为空");
        }
        if (rating < 1 || rating > 5) {
            return Result.error(400, "评分必须在1-5之间");
        }

        // 检查是否已评价过（同一订单同一商品只允许评价一次）
        if (orderId != null && !orderId.isEmpty()) {
            boolean exists = reviewRepository.existsByUserIdAndProductIdAndOrderId(userId, productId, orderId);
            if (exists) {
                return Result.error(409, "该商品已评价过");
            }
        }

        long now = System.currentTimeMillis();
        Review review = new Review();
        review.setReviewId(UUID.randomUUID().toString());
        review.setProductId(productId);
        review.setUserId(userId);
        review.setUserName(userName);
        review.setRating(rating);
        review.setContent(content);
        review.setOrderId(orderId);
        review.setOrderItemId(orderItemId);
        review.setCreatedAt(now);

        reviewRepository.save(review);

        // 更新商品平均评分
        updateProductRating(productId);

        Map<String, Object> result = buildReviewMap(review);
        return Result.success(result);
    }

    /**
     * 获取用户的所有评价
     */
    @GetMapping("/my")
    public Result<List<Map<String, Object>>> getMyReviews(HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");

        List<Review> reviews = reviewRepository.findByUserIdOrderByCreatedAtDesc(userId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (Review r : reviews) {
            result.add(buildReviewMap(r));
        }
        return Result.success(result);
    }

    /**
     * 获取评分统计（平均分、各星级数量）
     */
    @GetMapping("/stats/{productId}")
    public Result<Map<String, Object>> getReviewStats(@PathVariable String productId) {
        List<Review> reviews = reviewRepository.findByProductIdOrderByCreatedAtDesc(productId);
        double avg = reviews.stream().mapToInt(Review::getRating).average().orElse(0);
        long[] counts = new long[6]; // 1-5星
        for (Review r : reviews) {
            int idx = r.getRating();
            if (idx >= 1 && idx <= 5) counts[idx]++;
        }

        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("total", reviews.size());
        stats.put("average", Math.round(avg * 10.0) / 10.0);
        for (int i = 1; i <= 5; i++) {
            stats.put("star" + i, counts[i]);
        }
        return Result.success(stats);
    }

    private void updateProductRating(String productId) {
        productRepository.findById(productId).ifPresent(product -> {
            List<Review> reviews = reviewRepository.findByProductIdOrderByCreatedAtDesc(productId);
            double avg = reviews.stream().mapToInt(Review::getRating).average().orElse(0);
            product.setRating(Math.round(avg * 10.0) / 10.0);
            product.setUpdatedAt(System.currentTimeMillis());
            productRepository.save(product);
        });
    }

    private Map<String, Object> buildReviewMap(Review r) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("reviewId", r.getReviewId());
        m.put("productId", r.getProductId());
        m.put("userId", r.getUserId());
        m.put("userName", r.getUserName());
        m.put("rating", r.getRating());
        m.put("content", r.getContent() != null ? r.getContent() : "");
        m.put("images", parseImages(r.getImages()));
        m.put("orderId", r.getOrderId());
        m.put("createdAt", r.getCreatedAt());
        return m;
    }

    private List<String> parseImages(String images) {
        if (images == null || images.isEmpty()) return Collections.emptyList();
        try {
            String cleaned = images.replaceAll("[\\[\\]\"]", "").trim();
            if (cleaned.isEmpty()) return Collections.emptyList();
            return Arrays.asList(cleaned.split("\\s*,\\s*"));
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }
}
