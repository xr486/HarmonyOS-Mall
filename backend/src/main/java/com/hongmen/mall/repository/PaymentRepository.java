package com.hongmen.mall.repository;

import com.hongmen.mall.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, String> {

    Optional<Payment> findFirstByOrderIdOrderByCreatedAtDesc(String orderId);

    Optional<Payment> findFirstByOrderNoOrderByCreatedAtDesc(String orderNo);

    Optional<Payment> findByTransactionNo(String transactionNo);

    List<Payment> findByOrderIdAndStatus(String orderId, String status);

    List<Payment> findByUserIdOrderByCreatedAtDesc(String userId);

    List<Payment> findByOrderIdOrderByCreatedAtDesc(String orderId);
}
