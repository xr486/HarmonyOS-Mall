package com.hongmen.mall.payment.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.payment.dto.PaymentRecordDTO;
import com.hongmen.mall.payment.dto.RefundRecordDTO;
import com.hongmen.mall.payment.dto.RefundRequest;
import com.hongmen.mall.payment.service.PaymentRecordService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/v1/payment")
@RequiredArgsConstructor
public class PaymentRecordController {

    private final PaymentRecordService paymentRecordService;

    @GetMapping("/records")
    public Result<List<PaymentRecordDTO>> getPaymentHistory(HttpServletRequest request) {
        String userId = getUserId(request);
        List<PaymentRecordDTO> records = paymentRecordService.getPaymentHistory(userId);
        return Result.success(records);
    }

    @GetMapping("/records/{orderId}")
    public Result<List<PaymentRecordDTO>> getOrderPaymentHistory(@PathVariable String orderId, HttpServletRequest request) {
        getUserId(request);
        List<PaymentRecordDTO> records = paymentRecordService.getPaymentHistoryByOrder(orderId);
        return Result.success(records);
    }

    @PostMapping("/refund")
    public Result<RefundRecordDTO> createRefund(@RequestBody RefundRequest refundRequest, HttpServletRequest request) {
        String userId = getUserId(request);
        log.info("用户发起退款: userId={}, paymentId={}", userId, refundRequest.getPaymentId());
        RefundRecordDTO record = paymentRecordService.createRefund(refundRequest);
        return Result.success(record);
    }

    @GetMapping("/refund/{orderId}")
    public Result<List<RefundRecordDTO>> getRefundRecords(@PathVariable String orderId, HttpServletRequest request) {
        getUserId(request);
        List<RefundRecordDTO> records = paymentRecordService.getRefundRecords(orderId);
        return Result.success(records);
    }

    @PostMapping("/refund/{refundId}/confirm")
    public Result<String> confirmRefund(@PathVariable String refundId, HttpServletRequest request) {
        getUserId(request);
        paymentRecordService.confirmRefund(refundId);
        return Result.success("退款确认成功");
    }

    private String getUserId(HttpServletRequest request) {
        String userId = request.getHeader("X-User-Id");
        if (userId == null || userId.isEmpty()) {
            userId = "default_user";
        }
        return userId;
    }
}
