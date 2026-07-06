package com.hongmen.mall.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.entity.Address;
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
        // 填充订单商品明细，便于前端列表展示
        for (Order order : orders) {
            order.setItems(orderItemRepository.findByOrderId(order.getOrderId()));
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
            order.setItems(items);
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
            // 获取前端传入的要结算的购物车项ID
            Object cartIdsObj = body.get("cartIds");
            List<String> cartIds = new ArrayList<>();
            if (cartIdsObj instanceof List<?>) {
                for (Object id : (List<?>) cartIdsObj) {
                    cartIds.add(String.valueOf(id));
                }
            }

            // 兼容旧逻辑：未传cartIds时取全部选中项
            List<CartItem> cartItems;
            if (cartIds.isEmpty()) {
                cartItems = cartItemRepository.findByUserId(userId).stream()
                        .filter(c -> Boolean.TRUE.equals(c.getChecked()))
                        .filter(c -> c.getQuantity() > 0)
                        .toList();
            } else {
                cartItems = cartItemRepository.findAllById(cartIds).stream()
                        .filter(c -> c.getUserId().equals(userId))
                        .filter(c -> c.getQuantity() > 0)
                        .toList();
            }

            if (cartItems.isEmpty()) {
                return Result.error(400, "没有可下单的商品");
            }

            // 处理收货地址
            String addressId = body.get("addressId") != null ? (String) body.get("addressId") : null;
            String addressSnapshot = null;
            if (addressId != null && !addressId.isEmpty()) {
                Optional<Address> addressOpt = addressRepository.findById(addressId);
                if (addressOpt.isPresent()) {
                    Address addr = addressOpt.get();
                    if (addr.getUserId().equals(userId)) {
                        addressSnapshot = addr.getName() + " " + addr.getPhone() + "\n"
                                + addr.getProvince() + addr.getCity() + addr.getDistrict() + addr.getDetail();
                    }
                }
            }

            // 处理备注
            String remark = body.get("remark") != null ? (String) body.get("remark") : null;

            // 创建订单
            long now = System.currentTimeMillis();
            long expireTime = now + 30 * 60 * 1000; // 30分钟支付超时
            Order order = new Order();
            order.setOrderId(UUID.randomUUID().toString());
            order.setUserId(userId);
            order.setOrderNo("HM" + now + String.format("%04d", (int) (Math.random() * 10000)));
            order.setRemark(remark);
            order.setStatus("pending_payment");
            order.setAddressId(addressId);
            order.setAddressSnapshot(addressSnapshot);
            order.setCreatedAt(now);
            order.setUpdatedAt(now);
            order.setExpireTime(expireTime);

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

            order.setItems(items);
            return Result.success(order);
        } catch (Exception e) {
            return Result.error(500, "下单失败: " + e.getMessage());
        }
    }

    @PutMapping("/{orderId}/cancel")
    @Transactional
    public Result<Order> cancelOrder(@PathVariable String orderId,
                                     HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");
        return orderRepository.findById(orderId).map(order -> {
            if (!order.getUserId().equals(userId))
                return Result.<Order>error(403, "无权限");
            if (!"pending_payment".equals(order.getStatus()))
                return Result.<Order>error(400, "仅待付款订单可取消");
            order.setStatus("cancelled");
            order.setUpdatedAt(System.currentTimeMillis());
            orderRepository.save(order);
            return Result.success(order);
        }).orElse(Result.error(404, "订单不存在"));
    }

    @PutMapping("/{orderId}/pay")
    @Transactional
    public Result<Order> payOrder(@PathVariable String orderId,
                                  HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");
        return orderRepository.findById(orderId).map(order -> {
            if (!order.getUserId().equals(userId))
                return Result.<Order>error(403, "无权限");
            if (!"pending_payment".equals(order.getStatus()))
                return Result.<Order>error(400, "仅待付款订单可支付");
            long now = System.currentTimeMillis();
            order.setStatus("pending_shipment");
            order.setPaidAt(now);
            order.setUpdatedAt(now);
            orderRepository.save(order);
            return Result.success(order);
        }).orElse(Result.error(404, "订单不存在"));
    }

    @PutMapping("/{orderId}/confirm")
    @Transactional
    public Result<Order> confirmReceipt(@PathVariable String orderId,
                                        HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");
        return orderRepository.findById(orderId).map(order -> {
            if (!order.getUserId().equals(userId))
                return Result.<Order>error(403, "无权限");
            if (!"pending_receipt".equals(order.getStatus()))
                return Result.<Order>error(400, "仅待收货订单可确认收货");
            long now = System.currentTimeMillis();
            order.setStatus("completed");
            order.setCompletedAt(now);
            order.setUpdatedAt(now);
            orderRepository.save(order);
            return Result.success(order);
        }).orElse(Result.error(404, "订单不存在"));
    }
}
