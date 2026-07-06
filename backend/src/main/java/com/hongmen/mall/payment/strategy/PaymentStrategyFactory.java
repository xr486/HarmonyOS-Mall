package com.hongmen.mall.payment.strategy;

import com.hongmen.mall.payment.config.PaymentConfig;
import com.hongmen.mall.payment.enums.PaymentMethodEnum;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.EnumMap;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class PaymentStrategyFactory {

    private final Map<PaymentMethodEnum, PaymentStrategy> strategyMap = new EnumMap<>(PaymentMethodEnum.class);
    private final AlipayPaymentStrategy alipayStrategy;
    private final WechatPaymentStrategy wechatStrategy;
    private final HuaweiPaymentStrategy huaweiStrategy;

    @jakarta.annotation.PostConstruct
    public void init() {
        strategyMap.put(PaymentMethodEnum.ALIPAY, alipayStrategy);
        strategyMap.put(PaymentMethodEnum.WECHAT_PAY, wechatStrategy);
        strategyMap.put(PaymentMethodEnum.HUAWEI_PAY, huaweiStrategy);
    }

    public PaymentStrategy getStrategy(PaymentMethodEnum method) {
        PaymentStrategy strategy = strategyMap.get(method);
        if (strategy == null) {
            throw new IllegalArgumentException("不支持的支付方式: " + method);
        }
        return strategy;
    }
}
