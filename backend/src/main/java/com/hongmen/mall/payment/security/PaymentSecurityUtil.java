package com.hongmen.mall.payment.security;

import lombok.extern.slf4j.Slf4j;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Slf4j
public class PaymentSecurityUtil {

    private static final String MASK_CHAR = "*";
    private static final int PHONE_PREFIX_LENGTH = 3;
    private static final int PHONE_SUFFIX_LENGTH = 4;
    private static final int CARD_PREFIX_LENGTH = 4;
    private static final int CARD_SUFFIX_LENGTH = 4;

    private PaymentSecurityUtil() {
    }

    public static String maskPhone(String phone) {
        if (phone == null || phone.length() < PHONE_PREFIX_LENGTH + PHONE_SUFFIX_LENGTH) {
            return phone;
        }
        int maskLength = phone.length() - PHONE_PREFIX_LENGTH - PHONE_SUFFIX_LENGTH;
        StringBuilder sb = new StringBuilder();
        sb.append(phone, 0, PHONE_PREFIX_LENGTH);
        for (int i = 0; i < maskLength; i++) {
            sb.append(MASK_CHAR);
        }
        sb.append(phone, phone.length() - PHONE_SUFFIX_LENGTH, phone.length());
        return sb.toString();
    }

    public static String maskBankCard(String cardNo) {
        if (cardNo == null || cardNo.length() < CARD_PREFIX_LENGTH + CARD_SUFFIX_LENGTH) {
            return cardNo;
        }
        int maskLength = cardNo.length() - CARD_PREFIX_LENGTH - CARD_SUFFIX_LENGTH;
        StringBuilder sb = new StringBuilder();
        sb.append(cardNo, 0, CARD_PREFIX_LENGTH);
        for (int i = 0; i < maskLength; i++) {
            sb.append(MASK_CHAR);
        }
        sb.append(cardNo, cardNo.length() - CARD_SUFFIX_LENGTH, cardNo.length());
        return sb.toString();
    }

    public static String maskEmail(String email) {
        if (email == null || !email.contains("@")) {
            return email;
        }
        String[] parts = email.split("@");
        String local = parts[0];
        String domain = parts[1];
        if (local.length() <= 2) {
            return local.charAt(0) + MASK_CHAR + "@" + domain;
        }
        return local.charAt(0) + MASK_CHAR.repeat(Math.min(local.length() - 2, 3)) + local.charAt(local.length() - 1) + "@" + domain;
    }

    public static String maskName(String name) {
        if (name == null || name.isEmpty()) {
            return name;
        }
        if (name.length() == 1) {
            return MASK_CHAR;
        }
        if (name.length() == 2) {
            return MASK_CHAR + name.substring(1);
        }
        StringBuilder sb = new StringBuilder();
        sb.append(name, 0, 1);
        for (int i = 1; i < name.length() - 1; i++) {
            sb.append(MASK_CHAR);
        }
        sb.append(name, name.length() - 1, name.length());
        return sb.toString();
    }

    public static String generateNonce() {
        return UUID.randomUUID().toString().replace("-", "");
    }

    public static boolean verifyTimestamp(String timestampStr, long maxAgeMs) {
        try {
            long timestamp = Long.parseLong(timestampStr);
            long now = System.currentTimeMillis();
            long age = Math.abs(now - timestamp);
            return age <= maxAgeMs;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    public static String generateReplayToken(String orderId, String timestamp, String nonce) {
        try {
            String raw = orderId + "|" + timestamp + "|" + nonce;
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(raw.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            log.error("SHA-256 not available", e);
            return orderId + "_" + timestamp + "_" + nonce;
        }
    }

    public static boolean verifyReplayToken(String orderId, String timestamp, String nonce, String token) {
        String expected = generateReplayToken(orderId, timestamp, nonce);
        return expected.equals(token);
    }

    public static String maskOrderNo(String orderNo) {
        if (orderNo == null || orderNo.length() <= 8) {
            return orderNo;
        }
        return orderNo.substring(0, 4) + "****" + orderNo.substring(orderNo.length() - 4);
    }

    public static String maskAmount(Object amount) {
        if (amount == null) {
            return "***";
        }
        return String.format("¥***");
    }

    public static void validateRequestSign(String orderId, String timestamp, String nonce, String sign, long replayWindowMs) {
        if (orderId == null || orderId.isEmpty()) {
            throw new IllegalArgumentException("orderId不能为空");
        }
        if (timestamp == null || !verifyTimestamp(timestamp, replayWindowMs)) {
            throw new IllegalArgumentException("请求已过期或被篡改");
        }
        if (nonce == null || nonce.isEmpty()) {
            throw new IllegalArgumentException("nonce不能为空");
        }
        if (sign == null || !verifyReplayToken(orderId, timestamp, nonce, sign)) {
            throw new IllegalArgumentException("请求签名验证失败");
        }
    }
}
