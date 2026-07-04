package com.hongmen.mall.config;

import com.hongmen.mall.entity.Category;
import com.hongmen.mall.entity.Product;
import com.hongmen.mall.repository.CategoryRepository;
import com.hongmen.mall.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final CategoryRepository categoryRepository;
    private final ProductRepository productRepository;

    @Override
    public void run(String... args) {
        if (categoryRepository.count() > 0) {
            log.info("数据已存在，跳过初始化");
            return;
        }
        log.info("开始初始化测试数据...");
        initCategories();
        initProducts();
        log.info("测试数据初始化完成");
    }

    private void initCategories() {
        List<Category> categories = new ArrayList<>();
        categories.add(createCategory("cat_001", "手机数码", 1));
        categories.add(createCategory("cat_002", "电脑办公", 2));
        categories.add(createCategory("cat_003", "家用电器", 3));
        categories.add(createCategory("cat_004", "服饰鞋包", 4));
        categories.add(createCategory("cat_005", "食品生鲜", 5));
        categories.add(createCategory("cat_006", "美妆护肤", 6));
        categoryRepository.saveAll(categories);
        log.info("初始化 {} 个分类", categories.size());
    }

    private void initProducts() {
        List<Product> products = new ArrayList<>();

        products.add(createProduct("prod_001", "华为Mate 60 Pro", "旗舰手机 麒麟芯片 卫星通信", 699900L,
                799900L, 100, "cat_001", "华为", 4.9, 1523,
                30.254, 120.150));

        products.add(createProduct("prod_002", "Apple iPhone 15", "A17 Pro芯片 4800万像素", 599900L,
                699900L, 80, "cat_001", "Apple", 4.8, 2341,
                30.260, 120.160));

        products.add(createProduct("prod_003", "MacBook Pro 14", "M3芯片 18GB内存 512GB存储", 1499900L,
                1699900L, 50, "cat_002", "Apple", 4.9, 892,
                30.255, 120.155));

        products.add(createProduct("prod_004", "戴尔XPS 15", "13代i7 16GB 1TB 3.5K OLED", 999900L,
                1199900L, 30, "cat_002", "戴尔", 4.7, 467,
                31.230, 121.470));

        products.add(createProduct("prod_005", "美的空调 1.5匹", "新一级能效 变频冷暖 自清洁", 329900L,
                399900L, 200, "cat_003", "美的", 4.6, 3156,
                30.252, 120.148));

        products.add(createProduct("prod_006", "海尔冰箱 500L", "风冷无霜 双变频 干湿分储", 459900L,
                529900L, 60, "cat_003", "海尔", 4.8, 1203,
                31.235, 121.475));

        products.add(createProduct("prod_007", "Nike Air Jordan 1", "经典复刻 高帮板鞋", 129900L,
                149900L, 300, "cat_004", "Nike", 4.7, 4521,
                30.250, 120.152));

        products.add(createProduct("prod_008", "三只松鼠坚果礼盒", "每日坚果 混合装 750g", 8990L,
                12990L, 500, "cat_005", "三只松鼠", 4.5, 8932,
                30.257, 120.153));

        products.add(createProduct("prod_009", "兰蔻小黑瓶精华", "第二代 修护维稳 30ml", 76000L,
                95000L, 150, "cat_006", "兰蔻", 4.8, 2345,
                31.232, 121.468));

        products.add(createProduct("prod_010", "索尼WH-1000XM5", "头戴式无线降噪耳机", 249900L,
                299900L, 90, "cat_001", "索尼", 4.9, 678,
                30.256, 120.158));

        productRepository.saveAll(products);
        log.info("初始化 {} 个商品（含经纬度坐标）", products.size());
    }

    private Category createCategory(String id, String name, Integer sortOrder) {
        Category category = new Category();
        category.setCategoryId(id);
        category.setName(name);
        category.setSortOrder(sortOrder);
        category.setCreatedAt(System.currentTimeMillis());
        category.setUpdatedAt(System.currentTimeMillis());
        return category;
    }

    private Product createProduct(String productId, String name, String description,
                                   Long price, Long originalPrice, Integer stock,
                                   String categoryId, String brand, Double rating,
                                   Integer salesCount, Double latitude, Double longitude) {
        Product product = new Product();
        product.setProductId(productId);
        product.setName(name);
        product.setDescription(description);
        product.setPrice(price);
        product.setOriginalPrice(originalPrice);
        product.setStock(stock);
        product.setCategoryId(categoryId);
        product.setBrand(brand);
        product.setRating(rating);
        product.setSalesCount(salesCount);
        product.setLatitude(latitude);
        product.setLongitude(longitude);
        product.setCreatedAt(System.currentTimeMillis());
        return product;
    }
}
