package com.hongmen.mall.payment.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.payment.dto.PayRequest;
import com.hongmen.mall.payment.dto.PayResponse;
import com.hongmen.mall.payment.dto.PaymentResultDTO;
import com.hongmen.mall.payment.enums.PaymentMethodEnum;
import com.hongmen.mall.payment.enums.PaymentStatusEnum;
import com.hongmen.mall.payment.security.AntiReplayValidator;
import com.hongmen.mall.payment.service.PaymentService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/v1/payment")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;
    private final AntiReplayValidator antiReplayValidator;

    private String getUserId(HttpServletRequest request) {
        String userId = (String) request.getAttribute("userId");
        if (userId == null || userId.isEmpty()) {
            userId = request.getHeader("X-User-Id");
        }
        if (userId == null || userId.isEmpty()) {
            userId = "default_user";
        }
        return userId;
    }

    @PostMapping("/pay")
    public Result<PayResponse> pay(@RequestBody PayRequest payRequest, HttpServletRequest request) {
        try {
            antiReplayValidator.validate(request);
        } catch (SecurityException e) {
            return Result.error(429, e.getMessage());
        }
        String userId = getUserId(request);
        try {
            PayResponse response = paymentService.createPayRequest(payRequest, userId);
            return Result.success(response);
        } catch (IllegalArgumentException | IllegalStateException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            log.error("创建支付请求失败", e);
            return Result.error(500, "创建支付请求失败: " + e.getMessage());
        }
    }

    @GetMapping("/query/{orderId}")
    public Result<PaymentResultDTO> queryStatus(@PathVariable String orderId, HttpServletRequest request) {
        String userId = getUserId(request);
        try {
            PaymentResultDTO result = paymentService.queryPaymentStatus(orderId, userId);
            return Result.success(result);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            log.error("查询支付状态失败", e);
            return Result.error(500, "查询失败: " + e.getMessage());
        }
    }

    @PostMapping("/sync-result/{paymentId}")
    public Result<PaymentResultDTO> syncResult(@PathVariable String paymentId,
                                               @RequestBody Map<String, Object> body,
                                               HttpServletRequest request) {
        getUserId(request);
        try {
            String resultJson = (String) body.getOrDefault("resultJson", "{}");
            PaymentResultDTO result = paymentService.processSyncResult(paymentId, resultJson);
            return Result.success(result);
        } catch (Exception e) {
            log.error("处理同步结果失败", e);
            return Result.error(500, "处理失败: " + e.getMessage());
        }
    }

    @PostMapping("/notify/alipay")
    public String alipayNotify(HttpServletRequest request) {
        try {
            Map<String, String> params = new HashMap<>();
            request.getParameterMap().forEach((k, v) -> {
                if (v != null && v.length > 0) {
                    params.put(k, v[0]);
                }
            });
            log.info("收到支付宝回调: {}", params);
            PaymentResultDTO result = paymentService.handleCallback(PaymentMethodEnum.ALIPAY, params);
            return result.getStatus() == PaymentStatusEnum.SUCCESS ? "success" : "failure";
        } catch (Exception e) {
            log.error("支付宝回调处理异常", e);
            return "failure";
        }
    }

    @PostMapping("/notify/wechat")
    public String wechatNotify(HttpServletRequest request) {
        try {
            Map<String, String> params = new HashMap<>();
            request.getParameterMap().forEach((k, v) -> {
                if (v != null && v.length > 0) {
                    params.put(k, v[0]);
                }
            });
            log.info("收到微信支付回调: {}", params);
            PaymentResultDTO result = paymentService.handleCallback(PaymentMethodEnum.WECHAT_PAY, params);
            if (result.getStatus() == PaymentStatusEnum.SUCCESS) {
                return "<xml><return_code><![CDATA[SUCCESS]]></return_code><return_msg><![CDATA[OK]]></return_msg></xml>";
            }
            return "<xml><return_code><![CDATA[FAIL]]></return_code><return_msg><![CDATA[ERROR]]></return_msg></xml>";
        } catch (Exception e) {
            log.error("微信回调处理异常", e);
            return "<xml><return_code><![CDATA[FAIL]]></return_code><return_msg><![CDATA[ERROR]]></return_msg></xml>";
        }
    }

    @PostMapping("/notify/huawei")
    public Map<String, Object> huaweiNotify(@RequestBody Map<String, String> body) {
        Map<String, Object> response = new HashMap<>();
        try {
            log.info("收到华为支付回调: {}", body);
            PaymentResultDTO result = paymentService.handleCallback(PaymentMethodEnum.HUAWEI_PAY, body);
            if (result.getStatus() == PaymentStatusEnum.SUCCESS) {
                response.put("returnCode", "0");
                response.put("returnDesc", "success");
            } else {
                response.put("returnCode", "1");
                response.put("returnDesc", "fail");
            }
        } catch (Exception e) {
            log.error("华为回调处理异常", e);
            response.put("returnCode", "1");
            response.put("returnDesc", e.getMessage());
        }
        return response;
    }

    @PostMapping("/mock/success/{orderNo}")
    public Result<String> mockPaySuccess(@PathVariable String orderNo) {
        try {
            Map<String, String> mockParams = new HashMap<>();
            mockParams.put("out_trade_no", orderNo);
            mockParams.put("trade_no", "MOCK" + System.currentTimeMillis());
            mockParams.put("trade_status", "TRADE_SUCCESS");
            mockParams.put("total_amount", "0.01");
            mockParams.put("gmt_payment", new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()));
            paymentService.handleCallback(PaymentMethodEnum.ALIPAY, mockParams);
            return Result.success("模拟支付成功");
        } catch (Exception e) {
            log.error("模拟支付失败", e);
            return Result.error(500, e.getMessage());
        }
    }
}
