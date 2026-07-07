package com.hongmen.mall.payment.dto;

import lombok.Data;

@Data
public class RefundRecordDTO {
    private String refundId;
    private String paymentId;
    private String orderId;
    private String refundNo;
    private String transactionNo;
    private Double amount;
    private String reason;
    private String status;
    private Long createdAt;
}
