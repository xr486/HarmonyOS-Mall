package com.hongmen.mall.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.service.RecommendationTrackService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/recommendation")
@RequiredArgsConstructor
public class RecommendationTrackController {

    private final RecommendationTrackService trackService;

    @PostMapping("/track/click")
    public Result<String> trackClick(@RequestParam String productId,
                                      @RequestParam(required = false, defaultValue = "hot") String recType,
                                      @RequestParam(required = false) Integer rankPosition,
                                      @RequestParam(required = false, defaultValue = "homepage") String sourcePage,
                                      HttpServletRequest request) {
        String userId = request.getHeader("X-User-Id");
        if (userId == null || userId.isEmpty()) userId = "default_user";
        trackService.trackClick(userId, productId, recType, rankPosition, sourcePage);
        return Result.success("ok");
    }

    @PostMapping("/track/conversion")
    public Result<String> trackConversion(@RequestParam String productId,
                                           @RequestParam(required = false, defaultValue = "hot") String recType,
                                           @RequestParam(required = false) Integer rankPosition,
                                           @RequestParam(required = false, defaultValue = "homepage") String sourcePage,
                                           HttpServletRequest request) {
        String userId = request.getHeader("X-User-Id");
        if (userId == null || userId.isEmpty()) userId = "default_user";
        trackService.trackConversion(userId, productId, recType, rankPosition, sourcePage);
        return Result.success("ok");
    }

    @GetMapping("/stats")
    public Result<Map<String, Object>> getStats() {
        Map<String, Object> stats = trackService.getRecommendationStats();
        return Result.success(stats);
    }
}
