package com.hongmen.mall.payment.config;

import jakarta.annotation.PostConstruct;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.security.KeyPair;

import com.hongmen.mall.payment.util.RsaSignUtil;

@Data
@Configuration
@ConfigurationProperties(prefix = "payment")
public class PaymentConfig {

    private String notifyUrl = "http://localhost:8080/api/v1/payment/notify";

    private AlipayConfig alipay = new AlipayConfig();
    private WechatPayConfig wechat = new WechatPayConfig();
    private HuaweiPayConfig huawei = new HuaweiPayConfig();

    @Data
    public static class AlipayConfig {
        private boolean mock = true;
        private String appId = "2021000123654321";
        private String gatewayUrl = "https://openapi.alipaydev.com/gateway.do";
        private String appPrivateKey = "";
        private String alipayPublicKey = "";
        private String charset = "UTF-8";
        private String signType = "RSA2";
        private String returnUrl = "harmonymall://payment/return";
    }

    @Data
    public static class WechatPayConfig {
        private boolean mock = true;
        private String appId = "wx1234567890abcdef";
        private String mchId = "1234567890";
        private String apiV3Key = "your_api_v3_key_32_characters_here";
        private String merchantSerialNumber = "your_merchant_serial_number";
        private String privateKey = "";
    }

    @Data
    public static class HuaweiPayConfig {
        private boolean mock = true;
        private String appId = "123456789";
        private String cpId = "your_cp_id";
        private String merchantId = "your_merchant_id";
        private String privateKey = "";
        private String publicKey = "";
    }

    @PostConstruct
    public void init() throws Exception {
        if (alipay.getAppPrivateKey().isEmpty() || alipay.getAlipayPublicKey().isEmpty()) {
            KeyPair keyPair = RsaSignUtil.generateKeyPair();
            alipay.setAppPrivateKey(RsaSignUtil.getPrivateKeyString(keyPair.getPrivate()));
            alipay.setAlipayPublicKey(RsaSignUtil.getPublicKeyString(keyPair.getPublic()));
        }
        if (wechat.getPrivateKey().isEmpty()) {
            KeyPair keyPair = RsaSignUtil.generateKeyPair();
            wechat.setPrivateKey(RsaSignUtil.getPrivateKeyString(keyPair.getPrivate()));
        }
        if (huawei.getPrivateKey().isEmpty() || huawei.getPublicKey().isEmpty()) {
            KeyPair keyPair = RsaSignUtil.generateKeyPair();
            huawei.setPrivateKey(RsaSignUtil.getPrivateKeyString(keyPair.getPrivate()));
            huawei.setPublicKey(RsaSignUtil.getPublicKeyString(keyPair.getPublic()));
        }
    }
}
