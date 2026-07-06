package com.hongmen.mall.payment.enums;

import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;

@Getter
public enum PaymentMethodEnum {

    ALIPAY("alipay", "支付宝"),
    WECHAT_PAY("wechat", "微信支付"),
    HUAWEI_PAY("huawei", "华为支付");

    @JsonValue
    private final String code;
    private final String desc;

    PaymentMethodEnum(String code, String desc) {
        this.code = code;
        this.desc = desc;
    }

    public static PaymentMethodEnum getByCode(String code) {
        for (PaymentMethodEnum method : values()) {
            if (method.getCode().equals(code)) {
                return method;
            }
        }
        return null;
    }
}
