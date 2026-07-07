package com.hongmen.mall.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.entity.Review;
import com.hongmen.mall.repository.ReviewRepository;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
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
            Map<String, Object> m = new HashMap<>();
            m.put("reviewId", r.getReviewId());
            m.put("userId", r.getUserId());
            m.put("userName", r.getUserName());
            m.put("rating", r.getRating());
            m.put("content", r.getContent());
            m.put("images", parseImages(r.getImages()));
            m.put("createdAt", r.getCreatedAt());
            result.add(m);
        }
        return Result.success(result);
    }

    /**
     * 提交评价
     */
    @PostMapping
    public Result<Review> createReview(@RequestBody Map<String, Object> body,
                                       HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");

        String productId = (String) body.get("productId");
        Integer rating = body.get("rating") != null ? ((Number) body.get("rating")).intValue() : 5;
        String content = (String) body.get("content");
        String userName = body.get("userName") != null ? (String) body.get("userName") : "匿名用户";

        if (productId == null || productId.isEmpty()) {
            return Result.error(400, "商品ID不能为空");
        }
        if (rating < 1 || rating > 5) {
            return Result.error(400, "评分必须在1-5之间");
        }

        Review review = new Review();
        review.setReviewId(UUID.randomUUID().toString());
        review.setProductId(productId);
        review.setUserId(userId);
        review.setUserName(userName);
        review.setRating(rating);
        review.setContent(content);
        review.setCreatedAt(System.currentTimeMillis());

        reviewRepository.save(review);
        return Result.success(review);
    }

    private List<String> parseImages(String images) {
        if (images == null || images.isEmpty()) return Collections.emptyList();
        try {
            return Arrays.asList(images.split(","));
        } catch (Exception e) {
            return Collections.singletonList(images);
        }
    }
}
