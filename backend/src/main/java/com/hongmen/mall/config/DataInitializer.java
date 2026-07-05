package com.hongmen.mall.config;

import com.hongmen.mall.entity.Category;
import com.hongmen.mall.entity.Product;
import com.hongmen.mall.repository.CategoryRepository;
import com.hongmen.mall.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

/**
 * 测试数据初始化
 */
@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final CategoryRepository categoryRepository;
    private final ProductRepository productRepository;

    @Override
    public void run(String... args) {
        if (categoryRepository.count() > 0) return;

        long now = System.currentTimeMillis();

        // 分类
        Category c1 = categoryRepository.save(createCategory("cat-1", "手机数码", null, 1, now));
        Category c2 = categoryRepository.save(createCategory("cat-2", "电脑办公", null, 2, now));
        Category c3 = categoryRepository.save(createCategory("cat-3", "家用电器", null, 3, now));
        Category c4 = categoryRepository.save(createCategory("cat-4", "服饰鞋包", null, 4, now));
        Category c5 = categoryRepository.save(createCategory("cat-1-1", "智能手机", "cat-1", 1, now));
        Category c6 = categoryRepository.save(createCategory("cat-1-2", "智能手表", "cat-1", 2, now));
        Category c7 = categoryRepository.save(createCategory("cat-3-1", "空调", "cat-3", 1, now));
        Category c8 = categoryRepository.save(createCategory("cat-3-2", "冰箱", "cat-3", 2, now));

        // 商品
        productRepository.save(createProduct("p-1", "华为Mate 60 Pro", "华为旗舰手机，卫星通信，昆仑玻璃",
                6999.00, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Huawei+Mate+60+Pro+smartphone+product+photo+white+background&image_size=square",
                "cat-1-1", "华为", now, 9999));
        productRepository.save(createProduct("p-2", "iPhone 15 Pro Max", "Apple最新旗舰，A17 Pro芯片，钛金属设计",
                9999.00, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=iPhone+15+Pro+Max+product+photo+white+background&image_size=square",
                "cat-1-1", "苹果", now, 8888));
        productRepository.save(createProduct("p-3", "华为Watch GT 4", "智能手表，两周长续航，健康监测",
                2488.00, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Huawei+Watch+GT+4+smartwatch+product+photo+white+background&image_size=square",
                "cat-1-2", "华为", now, 5555));
        productRepository.save(createProduct("p-4", "MacBook Pro 14", "M3 Pro芯片，Liquid Retina XDR显示屏",
                14999.00, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=MacBook+Pro+14+laptop+product+photo+white+background&image_size=square",
                "cat-2", "苹果", now, 3333));
        productRepository.save(createProduct("p-5", "格力空调 大1.5匹", "新一级能效，变频冷暖，自清洁",
                3299.00, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Gree+air+conditioner+product+photo+white+background&image_size=square",
                "cat-3-1", "格力", now, 6666));
        productRepository.save(createProduct("p-6", "海尔冰箱 500L", "风冷无霜，干湿分储，智能温控",
                4299.00, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Haier+refrigerator+product+photo+white+background&image_size=square",
                "cat-3-2", "海尔", now, 4444));
    }

    private Category createCategory(String id, String name, String parentId, int sort, long time) {
        Category c = new Category();
        c.setCategoryId(id);
        c.setName(name);
        c.setParentId(parentId);
        c.setSortOrder(sort);
        c.setCreatedAt(time);
        c.setUpdatedAt(time);
        return c;
    }

    private Product createProduct(String id, String name, String desc, double price,
                                  String image, String catId, String brand, long time, int sales) {
        Product p = new Product();
        p.setProductId(id);
        p.setName(name);
        p.setDescription(desc);
        p.setPrice(price);
        p.setImage(image);
        p.setCategoryId(catId);
        p.setBrand(brand);
        p.setStock(100);
        p.setSalesCount(sales);
        p.setRating(4.5);
        p.setCreatedAt(time);
        p.setUpdatedAt(time);
        return p;
    }
}
