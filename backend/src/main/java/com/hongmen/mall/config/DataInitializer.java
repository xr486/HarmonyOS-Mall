package com.hongmen.mall.config;

import com.hongmen.mall.entity.Category;
import com.hongmen.mall.entity.Product;
import com.hongmen.mall.repository.CategoryRepository;
import com.hongmen.mall.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

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

        Category c1 = categoryRepository.save(createCategory("cat-1", "手机数码", null, 1));
        Category c2 = categoryRepository.save(createCategory("cat-2", "电脑办公", null, 2));
        Category c3 = categoryRepository.save(createCategory("cat-3", "家用电器", null, 3));
        Category c4 = categoryRepository.save(createCategory("cat-4", "服饰鞋包", null, 4));
        Category c5 = categoryRepository.save(createCategory("cat-5", "食品生鲜", null, 5));
        Category c6 = categoryRepository.save(createCategory("cat-6", "美妆护肤", null, 6));
        Category c1_1 = categoryRepository.save(createCategory("cat-1-1", "智能手机", "cat-1", 1));
        Category c1_2 = categoryRepository.save(createCategory("cat-1-2", "智能手表", "cat-1", 2));
        Category c3_1 = categoryRepository.save(createCategory("cat-3-1", "空调", "cat-3", 1));
        Category c3_2 = categoryRepository.save(createCategory("cat-3-2", "冰箱", "cat-3", 2));
        log.info("初始化 {} 个分类", 10);

        long now = System.currentTimeMillis();

        productRepository.save(createProduct("p-1", "华为Mate 60 Pro", "华为旗舰手机，卫星通信，昆仑玻璃",
                6999.00, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Huawei+Mate+60+Pro+smartphone+product+photo+white+background&image_size=square",
                "cat-1-1", "华为", now, 9999, 30.254, 120.150));

        productRepository.save(createProduct("p-2", "iPhone 15 Pro Max", "Apple最新旗舰，A17 Pro芯片，钛金属设计",
                9999.00, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=iPhone+15+Pro+Max+product+photo+white+background&image_size=square",
                "cat-1-1", "苹果", now, 8888, 30.260, 120.160));

        productRepository.save(createProduct("p-3", "华为Watch GT 4", "智能手表，两周长续航，健康监测",
                2488.00, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Huawei+Watch+GT+4+smartwatch+product+photo+white+background&image_size=square",
                "cat-1-2", "华为", now, 5555, 30.256, 120.155));

        productRepository.save(createProduct("p-4", "MacBook Pro 14", "M3 Pro芯片，Liquid Retina XDR显示屏",
                14999.00, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=MacBook+Pro+14+laptop+product+photo+white+background&image_size=square",
                "cat-2", "苹果", now, 3333, 30.255, 120.155));

        productRepository.save(createProduct("p-5", "格力空调 大1.5匹", "新一级能效，变频冷暖，自清洁",
                3299.00, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Gree+air+conditioner+product+photo+white+background&image_size=square",
                "cat-3-1", "格力", now, 6666, 30.252, 120.148));

        productRepository.save(createProduct("p-6", "海尔冰箱 500L", "风冷无霜，干湿分储，智能温控",
                4299.00, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Haier+refrigerator+product+photo+white+background&image_size=square",
                "cat-3-2", "海尔", now, 4444, 31.235, 121.475));

        productRepository.save(createProduct("p-7", "Nike Air Jordan 1", "经典复刻 高帮板鞋 潮流百搭",
                1299.00, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Nike+Air+Jordan+1+sneakers+product+photo+white+background&image_size=square",
                "cat-4", "Nike", now, 4521, 30.250, 120.152));

        productRepository.save(createProduct("p-8", "三只松鼠坚果礼盒", "每日坚果 混合装 750g 健康零食",
                89.90, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Three+Squirrels+nuts+gift+box+product+photo+white+background&image_size=square",
                "cat-5", "三只松鼠", now, 8932, 30.257, 120.153));

        productRepository.save(createProduct("p-9", "兰蔻小黑瓶精华", "第二代修护维稳精华 30ml 抗老修复",
                760.00, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Lancome+serum+product+photo+white+background&image_size=square",
                "cat-6", "兰蔻", now, 2345, 31.232, 121.468));

        productRepository.save(createProduct("p-10", "索尼WH-1000XM5", "头戴式无线降噪耳机 30小时续航",
                2499.00, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Sony+WH-1000XM5+headphones+product+photo+white+background&image_size=square",
                "cat-1", "索尼", now, 678, 30.256, 120.158));

        log.info("初始化 10 个商品（含经纬度坐标）");
    }

    private Category createCategory(String id, String name, String parentId, int sortOrder) {
        Category c = new Category();
        c.setCategoryId(id);
        c.setName(name);
        c.setParentId(parentId);
        c.setSortOrder(sortOrder);
        c.setCreatedAt(System.currentTimeMillis());
        c.setUpdatedAt(System.currentTimeMillis());
        return c;
    }

    private Product createProduct(String id, String name, String desc, double price,
                                  String image, String catId, String brand, long time,
                                  int sales, double latitude, double longitude) {
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
        p.setLatitude(latitude);
        p.setLongitude(longitude);
        p.setCreatedAt(time);
        p.setUpdatedAt(time);
        return p;
    }
}
