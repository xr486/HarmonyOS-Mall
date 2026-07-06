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

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

@Slf4j
@Component
@RequiredArgsConstructor
public class AlipayPaymentStrategy implements PaymentStrategy {

    private final PaymentConfig paymentConfig;

    @Override
    public PayResponse pay(Payment payment, Order order) {
        PaymentConfig.AlipayConfig config = paymentConfig.getAlipay();

        Map<String, String> bizContent = new HashMap<>();
        bizContent.put("out_trade_no", payment.getOrderNo());
        bizContent.put("total_amount", String.format("%.2f", payment.getAmount().doubleValue()));
        bizContent.put("subject", payment.getSubject());
        bizContent.put("body", payment.getBody());
        bizContent.put("product_code", "QUICK_MSECURITY_PAY");
        bizContent.put("timeout_express", "30m");

        Map<String, String> params = new TreeMap<>();
        params.put("app_id", config.getAppId());
        params.put("method", "alipay.trade.app.pay");
        params.put("charset", config.getCharset());
        params.put("sign_type", config.getSignType());
        params.put("timestamp", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));
        params.put("version", "1.0");
        params.put("notify_url", paymentConfig.getNotifyUrl() + "/alipay");
        params.put("return_url", config.getReturnUrl());
        params.put("biz_content", JSON.toJSONString(bizContent));

        try {
            String signContent = RsaSignUtil.getSignContent(params);
            String sign = RsaSignUtil.sign(signContent, config.getAppPrivateKey(), config.getCharset());
            params.put("sign", sign);

            StringBuilder orderStr = new StringBuilder();
            boolean first = true;
            for (Map.Entry<String, String> entry : params.entrySet()) {
                if (!first) {
                    orderStr.append("&");
                }
                orderStr.append(URLEncoder.encode(entry.getKey(), StandardCharsets.UTF_8))
                        .append("=")
                        .append(URLEncoder.encode(entry.getValue(), StandardCharsets.UTF_8));
                first = false;
            }

            if (config.isMock()) {
                log.info("[MOCK] 支付宝支付参数: orderStr={}", orderStr);
            }

            return PayResponse.builder()
                    .payParams(new HashMap<>(params))
                    .orderStr(orderStr.toString())
                    .build();
        } catch (Exception e) {
            log.error("支付宝签名失败", e);
            throw new RuntimeException("支付宝支付参数生成失败", e);
        }
    }

    @Override
    public PaymentResultDTO verifyCallbackAndParse(Map<String, String> params) {
        PaymentConfig.AlipayConfig config = paymentConfig.getAlipay();
        PaymentResultDTO result = PaymentResultDTO.builder()
                .orderNo(params.get("out_trade_no"))
                .transactionNo(params.get("trade_no"))
                .build();

        try {
            if (config.isMock()) {
                log.info("[MOCK] 支付宝回调: params={}", params);
                String tradeStatus = params.getOrDefault("trade_status", "TRADE_SUCCESS");
                if ("TRADE_SUCCESS".equals(tradeStatus) || "TRADE_FINISHED".equals(tradeStatus)) {
                    result.setStatus(PaymentStatusEnum.SUCCESS);
                    result.setPaidAt(System.currentTimeMillis());
                } else {
                    result.setStatus(PaymentStatusEnum.FAILED);
                    result.setErrorCode(tradeStatus);
                    result.setErrorMsg("支付失败");
                }
                return result;
            }

            String sign = params.get("sign");
            String content = RsaSignUtil.getSignContent(params);
            boolean verifyResult = RsaSignUtil.verify(content, sign, config.getAlipayPublicKey(), config.getCharset());

            if (!verifyResult) {
                log.warn("支付宝回调验签失败");
                result.setStatus(PaymentStatusEnum.FAILED);
                result.setErrorCode("SIGN_VERIFY_FAILED");
                result.setErrorMsg("验签失败");
                return result;
            }

            String tradeStatus = params.get("trade_status");
            if ("TRADE_SUCCESS".equals(tradeStatus) || "TRADE_FINISHED".equals(tradeStatus)) {
                result.setStatus(PaymentStatusEnum.SUCCESS);
                String gmtPayment = params.get("gmt_payment");
                if (gmtPayment != null) {
                    try {
                        result.setPaidAt(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(gmtPayment).getTime());
                    } catch (Exception ignored) {
                        result.setPaidAt(System.currentTimeMillis());
                    }
                }
                result.setPaidAmount(Double.parseDouble(params.get("total_amount")));
            } else {
                result.setStatus(PaymentStatusEnum.FAILED);
                result.setErrorCode(tradeStatus);
                result.setErrorMsg("交易未成功");
            }
        } catch (Exception e) {
            log.error("支付宝回调处理失败", e);
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
            Map<String, String> resultMap = JSON.parseObject(resultJson, Map.class);
            String resultStatus = resultMap.getOrDefault("resultStatus", "9000");

            if ("9000".equals(resultStatus)) {
                result.setStatus(PaymentStatusEnum.PROCESSING);
                result.setTransactionNo(resultMap.get("memo"));
            } else {
                result.setStatus(PaymentStatusEnum.FAILED);
                result.setErrorCode(resultStatus);
                Map<String, String> codeMap = new HashMap<>();
                codeMap.put("4000", "订单支付失败");
                codeMap.put("5000", "重复请求");
                codeMap.put("6001", "用户取消");
                codeMap.put("6002", "网络连接出错");
                codeMap.put("6004", "支付结果未知");
                result.setErrorMsg(codeMap.getOrDefault(resultStatus, "支付失败"));
            }
        } catch (Exception e) {
            log.error("解析支付宝同步结果失败", e);
            result.setStatus(PaymentStatusEnum.FAILED);
            result.setErrorCode("PARSE_ERROR");
            result.setErrorMsg(e.getMessage());
        }
        return result;
    }

    @Override
    public PaymentResultDTO queryOrderStatus(Payment payment) {
        PaymentConfig.AlipayConfig config = paymentConfig.getAlipay();
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
