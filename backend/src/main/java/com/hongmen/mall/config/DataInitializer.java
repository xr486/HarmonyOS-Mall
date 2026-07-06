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
        long now = System.currentTimeMillis();

        if (categoryRepository.count() == 0) {
            Category c1 = categoryRepository.save(createCategory("cat-1", "手机数码", null, 1, now));
            Category c2 = categoryRepository.save(createCategory("cat-2", "电脑办公", null, 2, now));
            Category c3 = categoryRepository.save(createCategory("cat-3", "家用电器", null, 3, now));
            Category c4 = categoryRepository.save(createCategory("cat-4", "服饰鞋包", null, 4, now));
            Category c5 = categoryRepository.save(createCategory("cat-1-1", "智能手机", "cat-1", 1, now));
            Category c6 = categoryRepository.save(createCategory("cat-1-2", "智能手表", "cat-1", 2, now));
            Category c7 = categoryRepository.save(createCategory("cat-3-1", "空调", "cat-3", 1, now));
            Category c8 = categoryRepository.save(createCategory("cat-3-2", "冰箱", "cat-3", 2, now));

            productRepository.save(createProduct("p-1", "华为Mate 60 Pro", "华为旗舰手机，卫星通信，昆仑玻璃",
                    6999L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Huawei+Mate+60+Pro+smartphone+product+photo+white+background&image_size=square",
                    "cat-1-1", "华为", now, 9999, 25.8400, 114.9200));
            productRepository.save(createProduct("p-2", "iPhone 15 Pro Max", "Apple最新旗舰，A17 Pro芯片，钛金属设计",
                    9999L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=iPhone+15+Pro+Max+product+photo+white+background&image_size=square",
                    "cat-1-1", "苹果", now, 8888, 25.8405, 114.9210));
            productRepository.save(createProduct("p-3", "华为Watch GT 4", "智能手表，两周长续航，健康监测",
                    2488L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Huawei+Watch+GT+4+smartwatch+product+photo+white+background&image_size=square",
                    "cat-1-2", "华为", now, 5555, 25.8395, 114.9190));
            productRepository.save(createProduct("p-4", "MacBook Pro 14", "M3 Pro芯片，Liquid Retina XDR显示屏",
                    14999L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=MacBook+Pro+14+laptop+product+photo+white+background&image_size=square",
                    "cat-2", "苹果", now, 3333, 25.8410, 114.9205));
            productRepository.save(createProduct("p-5", "格力空调 大1.5匹", "新一级能效，变频冷暖，自清洁",
                    3299L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Gree+air+conditioner+product+photo+white+background&image_size=square",
                    "cat-3-1", "格力", now, 6666, 25.8390, 114.9215));
            productRepository.save(createProduct("p-6", "海尔冰箱 500L", "风冷无霜，干湿分储，智能温控",
                    4299L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Haier+refrigerator+product+photo+white+background&image_size=square",
                    "cat-3-2", "海尔", now, 4444, 25.8408, 114.9185));
            productRepository.save(createProduct("p-7", "小米14 Ultra", "徕卡光学镜头，骁龙8 Gen3",
                    5999L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Xiaomi+14+Ultra+smartphone+product+photo+white+background&image_size=square",
                    "cat-1-1", "小米", now, 7777, 25.8420, 114.9220));
            productRepository.save(createProduct("p-8", "索尼WH-1000XM5", "旗舰降噪耳机，30小时续航",
                    2999L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Sony+WH-1000XM5+headphones+product+photo+white+background&image_size=square",
                    "cat-1-2", "索尼", now, 3333, 25.8380, 114.9175));
        } else {
            updateProductsWithLocation();
        }
    }

    private void updateProductsWithLocation() {
        java.util.List<Product> products = productRepository.findAll();
        boolean updated = false;

        for (Product p : products) {
            if (p.getLatitude() == null || p.getLongitude() == null) {
                double baseLat = 25.84;
                double baseLng = 114.92;
                double offsetLat = (Math.random() - 0.5) * 0.02;
                double offsetLng = (Math.random() - 0.5) * 0.02;
                p.setLatitude(baseLat + offsetLat);
                p.setLongitude(baseLng + offsetLng);
                updated = true;
            }
            if (p.getImages() == null || p.getImages().isEmpty()) {
                String image = getProductImage(p.getProductId());
                p.setImages(image);
                updated = true;
            }
            if (updated) {
                p.setUpdatedAt(System.currentTimeMillis());
                productRepository.save(p);
            }
        }

        if (updated) {
            System.out.println("[DataInitializer] Updated products with location data and images");
        }

        addNewProductsWithLocation();
    }

    private String getProductImage(String productId) {
        return switch (productId) {
            case "p-1" -> "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Huawei+Mate+60+Pro+smartphone+product+photo+white+background&image_size=square";
            case "p-2" -> "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=iPhone+15+Pro+Max+product+photo+white+background&image_size=square";
            case "p-3" -> "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Huawei+Watch+GT+4+smartwatch+product+photo+white+background&image_size=square";
            case "p-4" -> "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=MacBook+Pro+14+laptop+product+photo+white+background&image_size=square";
            case "p-5" -> "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Gree+air+conditioner+product+photo+white+background&image_size=square";
            case "p-6" -> "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Haier+refrigerator+product+photo+white+background&image_size=square";
            case "p-7" -> "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Xiaomi+14+Ultra+smartphone+product+photo+white+background&image_size=square";
            case "p-8" -> "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Sony+WH-1000XM5+headphones+product+photo+white+background&image_size=square";
            default -> "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=product+photo+white+background&image_size=square";
        };
    }

    private void addNewProductsWithLocation() {
        long now = System.currentTimeMillis();
        if (productRepository.findById("p-7").isEmpty()) {
            productRepository.save(createProduct("p-7", "小米14 Ultra", "徕卡光学镜头，骁龙8 Gen3",
                    5999L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Xiaomi+14+Ultra+smartphone+product+photo+white+background&image_size=square",
                    "cat-1-1", "小米", now, 7777, 25.8420, 114.9220));
            System.out.println("[DataInitializer] Added product p-7");
        }
        if (productRepository.findById("p-8").isEmpty()) {
            productRepository.save(createProduct("p-8", "索尼WH-1000XM5", "旗舰降噪耳机，30小时续航",
                    2999L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Sony+WH-1000XM5+headphones+product+photo+white+background&image_size=square",
                    "cat-1-2", "索尼", now, 3333, 25.8380, 114.9175));
            System.out.println("[DataInitializer] Added product p-8");
        }
        
        addProductIfNotExists("p-9", "荣耀Magic6 Pro", "青海湖电池，鹰眼相机，骁龙8 Gen3",
                4999L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Honor+Magic6+Pro+smartphone+product+photo+white+background&image_size=square",
                "cat-1-1", "荣耀", now, 6666, 25.8430, 114.9225);
        
        addProductIfNotExists("p-10", "OPPO Find X7 Ultra", "双潜望长焦，哈苏影像",
                5999L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=OPPO+Find+X7+Ultra+smartphone+product+photo+white+background&image_size=square",
                "cat-1-1", "OPPO", now, 5555, 25.8415, 114.9218);
        
        addProductIfNotExists("p-11", "vivo X100 Pro", "蔡司影像，天玑9300",
                5499L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Vivo+X100+Pro+smartphone+product+photo+white+background&image_size=square",
                "cat-1-1", "vivo", now, 4444, 25.8398, 114.9195);
        
        addProductIfNotExists("p-12", "Apple Watch Ultra 2", "钛金属表壳，精准双频GPS",
                6499L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Apple+Watch+Ultra+2+smartwatch+product+photo+white+background&image_size=square",
                "cat-1-2", "苹果", now, 2222, 25.8402, 114.9202);
        
        addProductIfNotExists("p-13", "三星Galaxy S24 Ultra", "钛金属边框，AI功能",
                8999L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Samsung+Galaxy+S24+Ultra+smartphone+product+photo+white+background&image_size=square",
                "cat-1-1", "三星", now, 3333, 25.8425, 114.9212);
        
        addProductIfNotExists("p-14", "联想ThinkPad X1 Carbon", "轻薄商务本，OLED屏幕",
                9999L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Lenovo+ThinkPad+X1+Carbon+laptop+product+photo+white+background&image_size=square",
                "cat-2", "联想", now, 2222, 25.8385, 114.9182);
        
        addProductIfNotExists("p-15", "戴森V15 Detect", "激光探测灰尘，声学感应",
                5499L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Dyson+V15+Detect+vacuum+cleaner+product+photo+white+background&image_size=square",
                "cat-3", "戴森", now, 1111, 25.8412, 114.9208);
        
        addProductIfNotExists("p-16", "AirPods Pro 2", "H2芯片，自适应降噪",
                1899L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Apple+AirPods+Pro+2+earbuds+product+photo+white+background&image_size=square",
                "cat-1-2", "苹果", now, 9999, 25.8392, 114.9192);
        
        addProductIfNotExists("p-17", "iPad Pro 12.9", "M2芯片，Liquid Retina XDR",
                8499L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=iPad+Pro+12.9+tablet+product+photo+white+background&image_size=square",
                "cat-2", "苹果", now, 4444, 25.8407, 114.9207);
        
        addProductIfNotExists("p-18", "美的洗衣机 10KG", "洗烘一体，变频节能",
                2999L, "https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Midea+washing+machine+product+photo+white+background&image_size=square",
                "cat-3", "美的", now, 5555, 25.8388, 114.9188);
    }
    
    private void addProductIfNotExists(String id, String name, String desc, long price,
                                       String image, String catId, String brand, long time,
                                       int sales, Double latitude, Double longitude) {
        if (productRepository.findById(id).isEmpty()) {
            productRepository.save(createProduct(id, name, desc, price, image, catId, brand, time, sales, latitude, longitude));
            System.out.println("[DataInitializer] Added product " + id);
        }
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

    private Product createProduct(String id, String name, String desc, long price,
                                  String image, String catId, String brand, long time, int sales,
                                  Double latitude, Double longitude) {
        Product p = new Product();
        p.setProductId(id);
        p.setName(name);
        p.setDescription(desc);
        p.setPrice(price);
        p.setImages(image);
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
