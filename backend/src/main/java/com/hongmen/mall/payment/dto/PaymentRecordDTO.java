package com.hongmen.mall.payment.dto;

import lombok.Data;

@Data
public class PaymentRecordDTO {
    private String paymentId;
    private String orderId;
    private String orderNo;
    private Double amount;
    private String method;
    private String methodText;
    private String status;
    private String statusText;
    private String transactionNo;
    private Long paidAt;
    private Long createdAt;
}
