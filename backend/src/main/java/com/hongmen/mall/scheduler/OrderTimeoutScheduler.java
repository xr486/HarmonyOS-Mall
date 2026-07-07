package com.hongmen.mall.scheduler;

import com.hongmen.mall.entity.Order;
import com.hongmen.mall.entity.OrderItem;
import com.hongmen.mall.entity.Product;
import com.hongmen.mall.repository.OrderItemRepository;
import com.hongmen.mall.repository.OrderRepository;
import com.hongmen.mall.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 订单超时自动取消定时任务
 * 每10秒扫描一次，将超过30秒未支付的待付款订单标记为已超时，并恢复商品库存
 */
@Component
@RequiredArgsConstructor
public class OrderTimeoutScheduler {

    private static final Logger logger = LoggerFactory.getLogger(OrderTimeoutScheduler.class);

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final ProductRepository productRepository;

    /**
     * 每10秒执行一次：扫描超时的待付款订单并标记为已超时
     */
    @Scheduled(fixedRate = 10000)
    @Transactional
    public void cancelExpiredOrders() {
        long now = System.currentTimeMillis();

        // 查找所有待付款且已超时的订单
        List<Order> allPendingOrders = orderRepository.findAll().stream()
                .filter(order -> "pending_payment".equals(order.getStatus()))
                .filter(order -> order.getExpireTime() != null && order.getExpireTime() < now)
                .toList();

        if (allPendingOrders.isEmpty()) {
            return;
        }

        logger.info("发现 {} 笔超时待付款订单，开始自动标记为已超时...", allPendingOrders.size());

        for (Order order : allPendingOrders) {
            try {
                // 标记为已超时
                order.setStatus("expired");
                order.setUpdatedAt(now);
                orderRepository.save(order);

                // 恢复商品库存
                List<OrderItem> items = orderItemRepository.findByOrderId(order.getOrderId());
                for (OrderItem item : items) {
                    productRepository.findById(item.getProductId()).ifPresent(product -> {
                        product.setStock(product.getStock() + item.getQuantity());
                        product.setUpdatedAt(now);
                        productRepository.save(product);
                        logger.debug("恢复商品 {} 库存 +{}，当前库存: {}",
                                product.getName(), item.getQuantity(), product.getStock());
                    });
                }

                logger.info("订单 {} (订单号: {}) 已超时，状态标记为 expired，库存已恢复",
                        order.getOrderId(), order.getOrderNo());
            } catch (Exception e) {
                logger.error("超时处理订单 {} 失败: {}", order.getOrderId(), e.getMessage(), e);
            }
        }
    }
}
