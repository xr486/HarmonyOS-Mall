package com.hongmen.mall.repository;

import com.hongmen.mall.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 订单明细仓库
 */
@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, String> {
    List<OrderItem> findByOrderId(String orderId);
    void deleteByOrderId(String orderId);
}
