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

import java.util.*;

@Slf4j
@Component
@RequiredArgsConstructor
public class WechatPaymentStrategy implements PaymentStrategy {

    private final PaymentConfig paymentConfig;

    @Override
    public PayResponse pay(Payment payment, Order order) {
        PaymentConfig.WechatPayConfig config = paymentConfig.getWechat();

        String prepayId = "wx" + System.currentTimeMillis() + UUID.randomUUID().toString().replace("-", "").substring(0, 10);

        String timestamp = String.valueOf(System.currentTimeMillis() / 1000);
        String nonceStr = UUID.randomUUID().toString().replace("-", "");
        String packageStr = "prepay_id=" + prepayId;

        Map<String, Object> payParams = new HashMap<>();
        payParams.put("appid", config.getAppId());
        payParams.put("partnerid", config.getMchId());
        payParams.put("prepayid", prepayId);
        payParams.put("package", packageStr);
        payParams.put("noncestr", nonceStr);
        payParams.put("timestamp", timestamp);

        try {
            String signStr = config.getAppId() + "\n" +
                    timestamp + "\n" +
                    nonceStr + "\n" +
                    packageStr + "\n";

            String sign;
            if (config.isMock()) {
                sign = Base64.getEncoder().encodeToString("mock_sign".getBytes());
                log.info("[MOCK] 微信支付参数: prepayId={}, params={}", prepayId, payParams);
            } else {
                sign = RsaSignUtil.sign(signStr, config.getPrivateKey(), "UTF-8");
            }
            payParams.put("sign", sign);

            return PayResponse.builder()
                    .payParams(payParams)
                    .build();
        } catch (Exception e) {
            log.error("微信支付签名失败", e);
            throw new RuntimeException("微信支付参数生成失败", e);
        }
    }

    @Override
    public PaymentResultDTO verifyCallbackAndParse(Map<String, String> params) {
        PaymentConfig.WechatPayConfig config = paymentConfig.getWechat();
        PaymentResultDTO result = PaymentResultDTO.builder()
                .orderNo(params.get("out_trade_no"))
                .transactionNo(params.get("transaction_id"))
                .build();

        try {
            if (config.isMock()) {
                log.info("[MOCK] 微信支付回调: params={}", params);
                String resultCode = params.getOrDefault("result_code", "SUCCESS");
                if ("SUCCESS".equals(resultCode)) {
                    result.setStatus(PaymentStatusEnum.SUCCESS);
                    result.setPaidAt(System.currentTimeMillis());
                    result.setPaidAmount(Double.parseDouble(params.getOrDefault("total_fee", "0")) / 100.0);
                } else {
                    result.setStatus(PaymentStatusEnum.FAILED);
                    result.setErrorCode(params.get("err_code"));
                    result.setErrorMsg(params.getOrDefault("err_code_des", "支付失败"));
                }
                return result;
            }

            result.setStatus(PaymentStatusEnum.PROCESSING);
        } catch (Exception e) {
            log.error("微信回调处理失败", e);
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
            int errCode = resultMap.get("errCode") != null ?
                    ((Number) resultMap.get("errCode")).intValue() : -1;

            if (errCode == 0) {
                result.setStatus(PaymentStatusEnum.PROCESSING);
            } else if (errCode == -2) {
                result.setStatus(PaymentStatusEnum.FAILED);
                result.setErrorCode("USER_CANCEL");
                result.setErrorMsg("用户取消支付");
            } else {
                result.setStatus(PaymentStatusEnum.FAILED);
                result.setErrorCode(String.valueOf(errCode));
                String errStr = resultMap.get("errStr") != null ? resultMap.get("errStr").toString() : "支付失败";
                result.setErrorMsg(errStr);
            }
        } catch (Exception e) {
            log.error("解析微信同步结果失败", e);
            result.setStatus(PaymentStatusEnum.FAILED);
            result.setErrorCode("PARSE_ERROR");
            result.setErrorMsg(e.getMessage());
        }
        return result;
    }

    @Override
    public PaymentResultDTO queryOrderStatus(Payment payment) {
        PaymentConfig.WechatPayConfig config = paymentConfig.getWechat();
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
