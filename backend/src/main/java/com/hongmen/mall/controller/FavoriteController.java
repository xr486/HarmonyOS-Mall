package com.hongmen.mall.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.entity.Favorite;
import com.hongmen.mall.entity.Product;
import com.hongmen.mall.repository.FavoriteRepository;
import com.hongmen.mall.repository.ProductRepository;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 商品收藏控制器
 */
@RestController
@RequestMapping("/api/v1/favorites")
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteRepository favoriteRepository;
    private final ProductRepository productRepository;

    private String getUserId(HttpServletRequest request) {
        return (String) request.getAttribute("userId");
    }

    /**
     * 获取收藏列表
     */
    @GetMapping
    public Result<List<Map<String, Object>>> getFavorites(HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");

        List<Favorite> favorites = favoriteRepository.findByUserIdOrderByCreatedAtDesc(userId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (Favorite fav : favorites) {
            productRepository.findById(fav.getProductId()).ifPresent(product -> {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("favoriteId", fav.getFavoriteId());
                m.put("favoritedAt", fav.getCreatedAt());
                m.put("productId", product.getProductId());
                m.put("name", product.getName());
                m.put("price", product.getPrice());
                m.put("images", parseImages(product.getImages()));
                m.put("rating", product.getRating());
                m.put("salesCount", product.getSalesCount());
                result.add(m);
            });
        }
        return Result.success(result);
    }

    /**
     * 切换收藏状态：未收藏则收藏，已收藏则取消
     */
    @PostMapping("/toggle")
    @Transactional
    public Result<Map<String, Object>> toggleFavorite(@RequestBody Map<String, Object> body,
                                                      HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");

        String productId = (String) body.get("productId");
        if (productId == null || productId.isEmpty()) {
            return Result.error(400, "商品ID不能为空");
        }

        Optional<Favorite> existing = favoriteRepository.findByUserIdAndProductId(userId, productId);
        Map<String, Object> result = new HashMap<>();

        if (existing.isPresent()) {
            // 已收藏 → 取消收藏
            favoriteRepository.delete(existing.get());
            result.put("collected", false);
            result.put("message", "已取消收藏");
        } else {
            // 未收藏 → 添加收藏
            Favorite fav = new Favorite();
            fav.setFavoriteId(UUID.randomUUID().toString());
            fav.setUserId(userId);
            fav.setProductId(productId);
            fav.setCreatedAt(System.currentTimeMillis());
            favoriteRepository.save(fav);
            result.put("collected", true);
            result.put("message", "已添加收藏");
        }
        return Result.success(result);
    }

    /**
     * 检查是否已收藏某商品
     */
    @GetMapping("/check/{productId}")
    public Result<Map<String, Object>> checkFavorite(@PathVariable String productId,
                                                     HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.success(Map.of("collected", false));

        boolean collected = favoriteRepository.existsByUserIdAndProductId(userId, productId);
        return Result.success(Map.of("collected", collected));
    }

    private List<String> parseImages(String images) {
        if (images == null || images.isEmpty()) return Collections.emptyList();
        if (images.startsWith("[")) {
            try {
                return Arrays.asList(images.replaceAll("[\\[\\]\"]", "").split(","));
            } catch (Exception e) {
                return Collections.emptyList();
            }
        }
        return Collections.singletonList(images);
    }
}
