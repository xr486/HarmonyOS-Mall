package com.hongmen.mall.payment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PayResponse {
    private String paymentId;
    private String orderId;
    private String paymentMethod;
    private Map<String, Object> payParams;
    private String orderStr;
}
