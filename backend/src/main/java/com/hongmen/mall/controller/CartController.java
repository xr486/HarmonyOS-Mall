package com.hongmen.mall.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.entity.CartItem;
import com.hongmen.mall.repository.CartItemRepository;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 购物车控制器
 */
@RestController
@RequestMapping("/api/v1/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartItemRepository cartItemRepository;

    private String getUserId(HttpServletRequest request) {
        return (String) request.getAttribute("userId");
    }

    @GetMapping
    public Result<List<CartItem>> listCart(HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");
        return Result.success(cartItemRepository.findByUserId(userId));
    }

    @PostMapping
    public Result<CartItem> addToCart(@RequestBody CartItem item, HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");

        // 已存在则合并数量
        String specs = item.getSpecs() != null ? item.getSpecs() : "";
        return cartItemRepository.findByUserIdAndProductIdAndSpecs(userId, item.getProductId(), specs)
                .map(existing -> {
                    existing.setQuantity(existing.getQuantity() + item.getQuantity());
                    existing.setUpdatedAt(System.currentTimeMillis());
                    return Result.success(cartItemRepository.save(existing));
                })
                .orElseGet(() -> {
                    item.setCartId(UUID.randomUUID().toString());
                    item.setUserId(userId);
                    if (item.getChecked() == null) item.setChecked(true);
                    long now = System.currentTimeMillis();
                    item.setCreatedAt(now);
                    item.setUpdatedAt(now);
                    return Result.success(cartItemRepository.save(item));
                });
    }

    @PutMapping("/{cartId}")
    public Result<CartItem> updateCartItem(@PathVariable String cartId, @RequestBody Map<String, Object> body,
                                           HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");

        return cartItemRepository.findById(cartId).map(item -> {
            if (!item.getUserId().equals(userId)) {
                return Result.<CartItem>error(403, "无权限");
            }
            if (body.containsKey("quantity")) {
                item.setQuantity(((Number) body.get("quantity")).intValue());
            }
            if (body.containsKey("checked")) {
                item.setChecked((Boolean) body.get("checked"));
            }
            item.setUpdatedAt(System.currentTimeMillis());
            cartItemRepository.save(item);
            return Result.success(item);
        }).orElse(Result.error(404, "购物车项不存在"));
    }

    @DeleteMapping("/{cartId}")
    public Result<String> removeFromCart(@PathVariable String cartId, HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");

        return cartItemRepository.findById(cartId).map(item -> {
            if (!item.getUserId().equals(userId)) {
                return Result.<String>error(403, "无权限");
            }
            cartItemRepository.delete(item);
            return Result.success("已移除");
        }).orElse(Result.error(404, "购物车项不存在"));
    }

    @PutMapping("/select-all")
    public Result<String> selectAll(@RequestBody Map<String, Object> body,
                                    HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");
        boolean selected = (Boolean) body.getOrDefault("selected", true);

        List<CartItem> items = cartItemRepository.findByUserId(userId);
        for (CartItem item : items) {
            item.setChecked(selected);
            item.setUpdatedAt(System.currentTimeMillis());
        }
        cartItemRepository.saveAll(items);
        return Result.success(selected ? "已全选" : "已取消全选");
    }

    @PutMapping("/{cartId}/select")
    public Result<CartItem> updateChecked(@PathVariable String cartId,
                                          @RequestBody Map<String, Object> body,
                                          HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");

        return cartItemRepository.findById(cartId).map(item -> {
            if (!item.getUserId().equals(userId)) {
                return Result.<CartItem>error(403, "无权限");
            }
            item.setChecked((Boolean) body.get("selected"));
            item.setUpdatedAt(System.currentTimeMillis());
            cartItemRepository.save(item);
            return Result.success(item);
        }).orElse(Result.error(404, "购物车项不存在"));
    }

    @DeleteMapping("/clear")
    public Result<String> clearCart(HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");
        cartItemRepository.deleteByUserId(userId);
        return Result.success("已清空");
    }
}
