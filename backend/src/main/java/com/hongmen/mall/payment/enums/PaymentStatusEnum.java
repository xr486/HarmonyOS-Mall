package com.hongmen.mall.payment.enums;

import lombok.Getter;

@Getter
public enum PaymentStatusEnum {

    PENDING("pending", "待支付"),
    PROCESSING("processing", "支付处理中"),
    SUCCESS("success", "支付成功"),
    FAILED("failed", "支付失败"),
    CLOSED("closed", "已关闭"),
    REFUNDED("refunded", "已退款");

    private final String code;
    private final String desc;

    PaymentStatusEnum(String code, String desc) {
        this.code = code;
        this.desc = desc;
    }
}
