package com.hongmen.mall.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.entity.Product;
import com.hongmen.mall.repository.ProductRepository;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("/api/v1/location")
@RequiredArgsConstructor
public class LocationController {

    private final ProductRepository productRepository;

    @Data
    public static class NearbyRequest {
        private Double latitude;
        private Double longitude;
        private Double radius = 50.0;
        private Integer limit = 20;
    }

    @Data
    public static class NearbyProduct {
        private Product product;
        private Double distance;
        private String distanceText;
    }

    @PostMapping("/nearby/products")
    public Result<List<NearbyProduct>> getNearbyProducts(@RequestBody NearbyRequest request) {
        log.info("查询附近商品: lat={}, lng={}, radius={}km, limit={}",
                request.getLatitude(), request.getLongitude(), request.getRadius(), request.getLimit());
        try {
            List<Product> allProducts = productRepository.findAll();
            log.info("数据库总商品数: {}", allProducts.size());

            List<NearbyProduct> nearbyList = new ArrayList<>();
            for (Product product : allProducts) {
                double lat = product.getLatitude() != null ? product.getLatitude() : 25.84;
                double lng = product.getLongitude() != null ? product.getLongitude() : 114.92;
                double distance = calculateDistance(
                        request.getLatitude(), request.getLongitude(),
                        lat, lng
                );
                log.debug("商品: {} ({}, {}) -> 距离: {}km",
                        product.getName(), lat, lng, distance);

                if (distance <= request.getRadius()) {
                    NearbyProduct np = new NearbyProduct();
                    np.setProduct(product);
                    np.setDistance(distance);
                    np.setDistanceText(formatDistance(distance));
                    nearbyList.add(np);
                }
            }
            nearbyList.sort(Comparator.comparingDouble(NearbyProduct::getDistance));
            List<NearbyProduct> result = nearbyList.stream()
                    .limit(request.getLimit())
                    .collect(Collectors.toList());
            log.info("找到附近商品数量: {}", result.size());
            return Result.success(result);
        } catch (Exception e) {
            log.error("查询附近商品失败", e);
            return Result.error("查询附近商品失败");
        }
    }

    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        double R = 6371;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    private String formatDistance(double distance) {
        if (distance < 1) {
            return String.format("%.0fm", distance * 1000);
        } else {
            return String.format("%.1fkm", distance);
        }
    }
}
