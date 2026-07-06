package com.hongmen.mall.payment.dto;

import lombok.Data;

@Data
public class PayRequest {
    private String orderId;
    private String paymentMethod;
}
