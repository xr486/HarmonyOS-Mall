package com.hongmen.mall.payment.dto;

import lombok.Data;

@Data
public class RefundRequest {
    private String paymentId;
    private Double amount;
    private String reason;
}
