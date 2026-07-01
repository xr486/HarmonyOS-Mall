
package com.hongmen.mall.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.entity.Category;
import com.hongmen.mall.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 分类控制器
 */
@RestController
@RequestMapping("/api/v1/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryRepository categoryRepository;

    /**
     * 获取所有分类
     */
    @GetMapping
    public Result<List<Category>> getAllCategories() {
        return Result.success(categoryRepository.findAll());
    }

    /**
     * 获取顶级分类
     */
    @GetMapping("/top")
    public Result<List<Category>> getTopLevelCategories() {
        return Result.success(categoryRepository.findByParentIdIsNullOrderBySortOrder());
    }

    /**
     * 获取子分类
     */
    @GetMapping("/{parentId}/children")
    public Result<List<Category>> getChildCategories(@PathVariable String parentId) {
        return Result.success(categoryRepository.findByParentIdOrderBySortOrder(parentId));
    }

    /**
     * 获取分类详情
     */
    @GetMapping("/{id}")
    public Result<Category> getCategoryById(@PathVariable String id) {
        return categoryRepository.findById(id)
                .map(Result::success)
                .orElse(Result.error(404, "分类不存在"));
    }
}
