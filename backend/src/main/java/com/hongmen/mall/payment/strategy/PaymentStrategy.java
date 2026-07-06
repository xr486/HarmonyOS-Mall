package com.hongmen.mall.payment.strategy;

import com.hongmen.mall.entity.Order;
import com.hongmen.mall.entity.Payment;
import com.hongmen.mall.payment.dto.PayResponse;
import com.hongmen.mall.payment.dto.PaymentResultDTO;

import java.util.Map;

public interface PaymentStrategy {

    PayResponse pay(Payment payment, Order order);

    PaymentResultDTO verifyCallbackAndParse(Map<String, String> params);

    PaymentResultDTO parseSyncResult(Payment payment, String resultJson);

    PaymentResultDTO queryOrderStatus(Payment payment);
}
