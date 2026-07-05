
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
     * 支持忽略空格/大小写匹配：用户输入 "华为Mate60" 也能匹配到 "华为Mate 60 Pro"
     */
    @GetMapping("/search")
    public Result<List<Product>> searchProducts(@RequestParam String keyword) {
        // 去除所有空白字符，统一为紧凑形式做精确匹配
        String normalizedKeyword = keyword.replaceAll("\\s+", "").toLowerCase();
        return Result.success(productRepository.findAll().stream()
                .filter(p -> {
                    if (normalizedKeyword.isEmpty()) return true;
                    // 对 name / description / brand 分别去空格后 contains
                    String normalizedName = (p.getName() != null ? p.getName() : "")
                            .replaceAll("\\s+", "").toLowerCase();
                    String normalizedDesc = (p.getDescription() != null ? p.getDescription() : "")
                            .replaceAll("\\s+", "").toLowerCase();
                    String normalizedBrand = (p.getBrand() != null ? p.getBrand() : "")
                            .replaceAll("\\s+", "").toLowerCase();
                    return normalizedName.contains(normalizedKeyword)
                            || normalizedDesc.contains(normalizedKeyword)
                            || normalizedBrand.contains(normalizedKeyword);
                })
                .toList());
    }
}
