package com.hongmen.mall.repository;

import com.hongmen.mall.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, String> {

    Optional<Payment> findByOrderId(String orderId);

    Optional<Payment> findByOrderNo(String orderNo);

    Optional<Payment> findByTransactionNo(String transactionNo);
}
