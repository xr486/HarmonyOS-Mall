
package com.hongmen.mall.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.entity.Product;
import com.hongmen.mall.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 商品控制器
 */
@RestController
@RequestMapping("/api/v1/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductRepository productRepository;

    /**
     * 获取所有商品
     */
    @GetMapping
    public Result<List<Product>> getAllProducts() {
        return Result.success(productRepository.findAll());
    }

    /**
     * 获取分类下的商品
     */
    @GetMapping("/category/{categoryId}")
    public Result<List<Product>> getProductsByCategory(@PathVariable String categoryId) {
        return Result.success(productRepository.findByCategoryId(categoryId));
    }

    /**
     * 获取商品详情
     */
    @GetMapping("/{id}")
    public Result<Product> getProductById(@PathVariable String id) {
        return productRepository.findById(id)
                .map(Result::success)
                .orElse(Result.error(404, "商品不存在"));
    }

    /**
     * 搜索商品
     */
    @GetMapping("/search")
    public Result<List<Product>> searchProducts(@RequestParam String keyword) {
        return Result.success(productRepository.findByNameContainingOrDescriptionContainingOrBrandContainingOrderBySalesCountDesc(
                keyword, keyword, keyword));
    }
}
