package com.hongmen.mall.repository;

import com.hongmen.mall.entity.PaymentRefund;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PaymentRefundRepository extends JpaRepository<PaymentRefund, String> {

    List<PaymentRefund> findByOrderIdOrderByCreatedAtDesc(String orderId);

    List<PaymentRefund> findByPaymentIdOrderByCreatedAtDesc(String paymentId);

    Optional<PaymentRefund> findByRefundNo(String refundNo);
}
