package com.hongmen.mall.payment.strategy;

import com.alibaba.fastjson.JSON;
import com.hongmen.mall.entity.Order;
import com.hongmen.mall.entity.Payment;
import com.hongmen.mall.payment.config.PaymentConfig;
import com.hongmen.mall.payment.dto.PayResponse;
import com.hongmen.mall.payment.dto.PaymentResultDTO;
import com.hongmen.mall.payment.enums.PaymentStatusEnum;
import com.hongmen.mall.payment.util.RsaSignUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.*;

@Slf4j
@Component
@RequiredArgsConstructor
public class HuaweiPaymentStrategy implements PaymentStrategy {

    private final PaymentConfig paymentConfig;

    @Override
    public PayResponse pay(Payment payment, Order order) {
        PaymentConfig.HuaweiPayConfig config = paymentConfig.getHuawei();

        String timestamp = String.valueOf(System.currentTimeMillis() / 1000);
        String nonceStr = UUID.randomUUID().toString().replace("-", "");
        String requestId = UUID.randomUUID().toString().replace("-", "");

        Map<String, Object> bizContent = new HashMap<>();
        bizContent.put("applicationID", config.getAppId());
        bizContent.put("cpID", config.getCpId());
        bizContent.put("merchantId", config.getMerchantId());
        bizContent.put("requestId", requestId);
        bizContent.put("productName", payment.getSubject());
        bizContent.put("productDesc", payment.getBody());
        bizContent.put("amount", String.valueOf(payment.getAmount().multiply(BigDecimal.valueOf(100)).longValue()));
        bizContent.put("currency", "CNY");
        bizContent.put("country", "CN");
        bizContent.put("merchantName", "鸿蒙商城");
        bizContent.put("extReserved", payment.getOrderNo());

        Map<String, Object> payParams = new HashMap<>();
        payParams.put("appid", config.getAppId());
        payParams.put("cpId", config.getCpId());
        payParams.put("merchantId", config.getMerchantId());
        payParams.put("productName", payment.getSubject());
        payParams.put("productDesc", payment.getBody());
        payParams.put("amount", String.valueOf(payment.getAmount().multiply(BigDecimal.valueOf(100)).longValue()));
        payParams.put("orderNo", payment.getOrderNo());
        payParams.put("requestId", requestId);
        payParams.put("timestamp", timestamp);
        payParams.put("nonceStr", nonceStr);
        payParams.put("bizContent", JSON.toJSONString(bizContent));

        try {
            String amountFen = String.valueOf(payment.getAmount().multiply(BigDecimal.valueOf(100)).longValue());
            String signContent = config.getAppId() + config.getCpId() +
                    payment.getOrderNo() + amountFen +
                    timestamp + nonceStr;

            String sign;
            if (config.isMock()) {
                sign = Base64.getEncoder().encodeToString("mock_huawei_sign".getBytes());
                log.info("[MOCK] 华为支付参数: params={}", payParams);
            } else {
                sign = RsaSignUtil.sign(signContent, config.getPrivateKey(), "UTF-8");
            }
            payParams.put("sign", sign);
            payParams.put("signType", "RSA256");

            return PayResponse.builder()
                    .payParams(payParams)
                    .build();
        } catch (Exception e) {
            log.error("华为支付签名失败", e);
            throw new RuntimeException("华为支付参数生成失败", e);
        }
    }

    @Override
    public PaymentResultDTO verifyCallbackAndParse(Map<String, String> params) {
        PaymentConfig.HuaweiPayConfig config = paymentConfig.getHuawei();
        PaymentResultDTO result = PaymentResultDTO.builder()
                .orderNo(params.get("extReserved") != null ? params.get("extReserved") : params.get("orderNo"))
                .transactionNo(params.get("tradeNo"))
                .build();

        try {
            if (config.isMock()) {
                log.info("[MOCK] 华为支付回调: params={}", params);
                String returnCode = params.getOrDefault("returnCode", "0");
                if ("0".equals(returnCode)) {
                    result.setStatus(PaymentStatusEnum.SUCCESS);
                    result.setPaidAt(System.currentTimeMillis());
                    String amount = params.get("amount");
                    if (amount != null) {
                        result.setPaidAmount(Double.parseDouble(amount) / 100.0);
                    }
                } else {
                    result.setStatus(PaymentStatusEnum.FAILED);
                    result.setErrorCode(returnCode);
                    result.setErrorMsg(params.getOrDefault("returnDesc", "支付失败"));
                }
                return result;
            }

            result.setStatus(PaymentStatusEnum.PROCESSING);
        } catch (Exception e) {
            log.error("华为回调处理失败", e);
            result.setStatus(PaymentStatusEnum.FAILED);
            result.setErrorCode("CALLBACK_ERROR");
            result.setErrorMsg(e.getMessage());
        }
        return result;
    }

    @Override
    public PaymentResultDTO parseSyncResult(Payment payment, String resultJson) {
        PaymentResultDTO result = PaymentResultDTO.builder()
                .paymentId(payment.getPaymentId())
                .orderId(payment.getOrderId())
                .orderNo(payment.getOrderNo())
                .build();
        try {
            Map<String, Object> resultMap = JSON.parseObject(resultJson, Map.class);
            int returnCode = resultMap.get("returnCode") != null ?
                    ((Number) resultMap.get("returnCode")).intValue() : -1;

            if (returnCode == 0) {
                result.setStatus(PaymentStatusEnum.PROCESSING);
                result.setTransactionNo(resultMap.get("tradeNo") != null ?
                        resultMap.get("tradeNo").toString() : null);
            } else if (returnCode == 1001) {
                result.setStatus(PaymentStatusEnum.FAILED);
                result.setErrorCode("USER_CANCEL");
                result.setErrorMsg("用户取消支付");
            } else if (returnCode == 1002) {
                result.setStatus(PaymentStatusEnum.FAILED);
                result.setErrorCode("NOT_INSTALLED");
                result.setErrorMsg("未安装华为移动服务或不支持华为支付");
            } else {
                result.setStatus(PaymentStatusEnum.FAILED);
                result.setErrorCode(String.valueOf(returnCode));
                String errDesc = resultMap.get("returnDesc") != null ?
                        resultMap.get("returnDesc").toString() : "支付失败";
                result.setErrorMsg(errDesc);
            }
        } catch (Exception e) {
            log.error("解析华为支付同步结果失败", e);
            result.setStatus(PaymentStatusEnum.FAILED);
            result.setErrorCode("PARSE_ERROR");
            result.setErrorMsg(e.getMessage());
        }
        return result;
    }

    @Override
    public PaymentResultDTO queryOrderStatus(Payment payment) {
        PaymentConfig.HuaweiPayConfig config = paymentConfig.getHuawei();
        PaymentResultDTO result = PaymentResultDTO.builder()
                .orderNo(payment.getOrderNo())
                .build();

        if (config.isMock()) {
            result.setStatus(PaymentStatusEnum.PROCESSING);
            return result;
        }

        result.setStatus(PaymentStatusEnum.PROCESSING);
        return result;
    }
}
