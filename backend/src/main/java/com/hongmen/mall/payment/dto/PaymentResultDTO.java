package com.hongmen.mall.payment.dto;

import com.hongmen.mall.payment.enums.PaymentStatusEnum;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentResultDTO {
    private String paymentId;
    private String orderId;
    private String orderNo;
    private PaymentStatusEnum status;
    private String transactionNo;
    private String errorCode;
    private String errorMsg;
    private Double paidAmount;
    private Long paidAt;
}
