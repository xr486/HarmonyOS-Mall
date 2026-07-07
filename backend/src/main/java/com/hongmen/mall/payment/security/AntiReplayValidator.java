package com.hongmen.mall.payment.security;

import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Component
public class AntiReplayValidator {

    private static final Map<String, Long> NONCE_STORE = new ConcurrentHashMap<>();
    private static final long MAX_AGE_MS = 300000;
    private static final long NONCE_EXPIRE_MS = 600000;

    static {
        Thread cleanup = new Thread(() -> {
            while (true) {
                try {
                    Thread.sleep(60000);
                    long now = System.currentTimeMillis();
                    NONCE_STORE.entrySet().removeIf(e -> now - e.getValue() > NONCE_EXPIRE_MS);
                } catch (InterruptedException ignored) {
                    break;
                }
            }
        }, "anti-replay-cleanup");
        cleanup.setDaemon(true);
        cleanup.start();
    }

    public void validate(HttpServletRequest request) {
        String timestamp = request.getHeader("X-Timestamp");
        String nonce = request.getHeader("X-Nonce");

        if (timestamp == null || nonce == null) {
            log.debug("防重放: 请求未携带X-Timestamp或X-Nonce头，跳过校验");
            return;
        }

        if (!PaymentSecurityUtil.verifyTimestamp(timestamp, MAX_AGE_MS)) {
            log.error("防重放攻击: 请求时间戳过期 timestamp={}", timestamp);
            throw new SecurityException("请求已过期，请重新发起");
        }

        Long existing = NONCE_STORE.putIfAbsent(nonce, System.currentTimeMillis());
        if (existing != null) {
            log.error("防重放攻击: 重复请求 nonce={}", nonce);
            throw new SecurityException("请勿重复提交");
        }
    }
}
