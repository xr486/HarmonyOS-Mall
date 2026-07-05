package com.hongmen.mall.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.entity.Product;
import com.hongmen.mall.entity.Recommendation;
import com.hongmen.mall.service.RecommendationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/recommendations")
@RequiredArgsConstructor
public class RecommendationController {

    private final RecommendationService recommendationService;

    @GetMapping("/user/{userId}")
    public Result<List<Recommendation>> getRecommendations(@PathVariable String userId) {
        List<Recommendation> recommendations = recommendationService.getRecommendationEntities(userId);
        return Result.success(recommendations);
    }

    @GetMapping("/user/{userId}/collaborative")
    public Result<List<Recommendation>> getCollaborativeRecommendations(@PathVariable String userId) {
        List<Recommendation> recommendations = recommendationService.getCollaborativeRecommendationEntities(userId);
        return Result.success(recommendations);
    }

    @GetMapping("/user/{userId}/content")
    public Result<List<Recommendation>> getContentRecommendations(@PathVariable String userId) {
        List<Recommendation> recommendations = recommendationService.getContentRecommendationEntities(userId);
        return Result.success(recommendations);
    }

    @PostMapping("/refresh/user/{userId}")
    public Result<String> refreshRecommendationsForUser(@PathVariable String userId) {
        recommendationService.refreshRecommendationsForUser(userId);
        return Result.success("Recommendations refreshed for user: " + userId);
    }

    @PostMapping("/refresh/all")
    public Result<String> refreshAllRecommendations() {
        recommendationService.refreshAllRecommendations();
        return Result.success("All recommendations refreshed");
    }

    @GetMapping("/user/{userId}/similar")
    public Result<List<Product>> getSimilarProducts(@PathVariable String userId) {
        List<Product> recommendations = recommendationService.getSimilarProductsByLatestBrowse(userId);
        return Result.success(recommendations);
    }
}