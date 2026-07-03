package com.hongmen.mall.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.entity.Order;
import com.hongmen.mall.entity.OrderItem;
import com.hongmen.mall.entity.CartItem;
import com.hongmen.mall.repository.OrderRepository;
import com.hongmen.mall.repository.OrderItemRepository;
import com.hongmen.mall.repository.CartItemRepository;
import com.hongmen.mall.repository.AddressRepository;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 订单控制器
 */
@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final CartItemRepository cartItemRepository;
    private final AddressRepository addressRepository;

    private String getUserId(HttpServletRequest request) {
        return (String) request.getAttribute("userId");
    }

    @GetMapping
    public Result<List<Order>> listOrders(@RequestParam(required = false) String status,
                                          HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");
        List<Order> orders;
        if (status != null && !status.isEmpty()) {
            orders = orderRepository.findByUserIdAndStatus(userId, status);
        } else {
            orders = orderRepository.findByUserIdOrderByCreatedAtDesc(userId);
        }
        return Result.success(orders);
    }

    @GetMapping("/{orderId}")
    public Result<Map<String, Object>> getOrderDetail(@PathVariable String orderId,
                                                       HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");
        return orderRepository.findById(orderId).map(order -> {
            if (!order.getUserId().equals(userId))
                return Result.<Map<String, Object>>error(403, "无权限");
            List<OrderItem> items = orderItemRepository.findByOrderId(orderId);
            Map<String, Object> detail = new HashMap<>();
            detail.put("order", order);
            detail.put("items", items);
            return Result.success(detail);
        }).orElse(Result.error(404, "订单不存在"));
    }

    @PostMapping
    @Transactional
    public Result<Order> createOrder(@RequestBody Map<String, Object> body,
                                     HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");

        try {
            // 获取购物车选中项
            List<CartItem> cartItems = cartItemRepository.findByUserId(userId).stream()
                    .filter(c -> Boolean.TRUE.equals(c.getChecked()))
                    .filter(c -> c.getQuantity() > 0)
                    .toList();

            if (cartItems.isEmpty()) {
                return Result.error(400, "没有可下单的商品");
            }

            // 处理备注
            String remark = body.get("remark") != null ? (String) body.get("remark") : null;

            // 创建订单
            long now = System.currentTimeMillis();
            Order order = new Order();
            order.setOrderId(UUID.randomUUID().toString());
            order.setUserId(userId);
            order.setOrderNo("HM" + now + String.format("%04d", (int) (Math.random() * 10000)));
            order.setRemark(remark);
            order.setStatus("pending_payment");
            order.setCreatedAt(now);
            order.setUpdatedAt(now);

            double total = 0;
            List<OrderItem> items = new ArrayList<>();
            for (CartItem cart : cartItems) {
                OrderItem item = new OrderItem();
                item.setItemId(UUID.randomUUID().toString());
                item.setOrderId(order.getOrderId());
                item.setProductId(cart.getProductId());
                item.setProductName(cart.getProductName());
                item.setProductImage(cart.getProductImage());
                item.setPrice(cart.getPrice());
                item.setQuantity(cart.getQuantity());
                item.setSpecs(cart.getSpecs());
                items.add(item);
                total += cart.getPrice() * cart.getQuantity();
            }
            order.setTotalAmount(total);

            orderRepository.save(order);
            orderItemRepository.saveAll(items);
            cartItemRepository.deleteAll(cartItems);

            return Result.success(order);
        } catch (Exception e) {
            return Result.error(500, "下单失败: " + e.getMessage());
        }
    }
}
