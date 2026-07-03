package com.hongmen.mall.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.entity.User;
import com.hongmen.mall.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 认证控制器 — 手机号+密码注册/登录 + 验证码登录
 */
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserRepository userRepository;

    private static final Map<String, String> tokenStore = new ConcurrentHashMap<>();

    /**
     * 发送验证码（开发模式固定123456）
     */
    @PostMapping("/send-code")
    public Result<Map<String, String>> sendVerifyCode(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        if (phone == null || phone.isBlank()) {
            return Result.error(400, "手机号不能为空");
        }
        return Result.success(Map.of("code", "123456", "message", "验证码已发送（开发模式固定123456）"));
    }

    /**
     * 注册：手机号 + 密码 + 验证码
     */
    @PostMapping("/register")
    public Result<Map<String, Object>> register(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        String password = body.get("password");
        String code = body.get("code");

        if (phone == null || phone.isBlank()) {
            return Result.error(400, "手机号不能为空");
        }
        if (password == null || password.length() < 6) {
            return Result.error(400, "密码长度至少6位");
        }
        if (code == null || code.isBlank()) {
            return Result.error(400, "验证码不能为空");
        }
        if (!"123456".equals(code)) {
            return Result.error(400, "验证码错误");
        }
        if (userRepository.findByPhone(phone).isPresent()) {
            return Result.error(400, "该手机号已注册");
        }

        long now = System.currentTimeMillis();
        User user = new User();
        user.setUserId(UUID.randomUUID().toString());
        user.setPhone(phone);
        user.setPassword(sha256(password));
        user.setNickname("用户" + phone.substring(phone.length() - 4));
        user.setCreatedAt(now);
        user.setUpdatedAt(now);
        userRepository.save(user);

        String token = UUID.randomUUID().toString();
        tokenStore.put(token, user.getUserId());

        return Result.success(Map.of(
                "token", token,
                "userId", user.getUserId(),
                "phone", user.getPhone(),
                "nickname", user.getNickname()
        ));
    }

    /**
     * 密码登录
     */
    @PostMapping("/login/password")
    public Result<Map<String, Object>> loginByPassword(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        String password = body.get("password");

        if (phone == null || phone.isBlank()) {
            return Result.error(400, "手机号不能为空");
        }
        if (password == null || password.isBlank()) {
            return Result.error(400, "密码不能为空");
        }

        User user = userRepository.findByPhone(phone).orElse(null);
        if (user == null) {
            return Result.error(400, "该手机号未注册");
        }
        if (!sha256(password).equals(user.getPassword())) {
            return Result.error(400, "密码错误");
        }

        String token = UUID.randomUUID().toString();
        tokenStore.put(token, user.getUserId());

        return Result.success(Map.of(
                "token", token,
                "userId", user.getUserId(),
                "phone", user.getPhone(),
                "nickname", user.getNickname()
        ));
    }

    /**
     * 验证码登录（老用户直接登录，新用户自动注册）
     */
    @PostMapping("/login")
    public Result<Map<String, Object>> loginByCode(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        String code = body.get("code");

        if (phone == null || phone.isBlank()) {
            return Result.error(400, "手机号不能为空");
        }
        if (code == null || code.isBlank()) {
            return Result.error(400, "验证码不能为空");
        }
        if (!"123456".equals(code)) {
            return Result.error(400, "验证码错误");
        }

        long now = System.currentTimeMillis();
        User user = userRepository.findByPhone(phone).orElseGet(() -> {
            User newUser = new User();
            newUser.setUserId(UUID.randomUUID().toString());
            newUser.setPhone(phone);
            newUser.setNickname("用户" + phone.substring(phone.length() - 4));
            newUser.setCreatedAt(now);
            newUser.setUpdatedAt(now);
            return userRepository.save(newUser);
        });

        String token = UUID.randomUUID().toString();
        tokenStore.put(token, user.getUserId());

        return Result.success(Map.of(
                "token", token,
                "userId", user.getUserId(),
                "phone", user.getPhone(),
                "nickname", user.getNickname()
        ));
    }

    @PostMapping("/logout")
    public Result<String> logout(@RequestHeader(value = "Authorization", required = false) String auth) {
        if (auth != null && auth.startsWith("Bearer ")) {
            tokenStore.remove(auth.substring(7));
        }
        return Result.success("已退出");
    }

    public static String getUserIdByToken(String token) {
        return tokenStore.get(token);
    }

    private static String sha256(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }
}
