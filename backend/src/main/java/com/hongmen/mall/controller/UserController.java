package com.hongmen.mall.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.entity.User;
import com.hongmen.mall.repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 用户控制器
 */
@RestController
@RequestMapping("/api/v1/user")
@RequiredArgsConstructor
public class UserController {

    private final UserRepository userRepository;

    /**
     * 获取当前登录用户信息
     */
    @GetMapping("/info")
    public Result<User> getUserInfo(HttpServletRequest request) {
        String userId = (String) request.getAttribute("userId");
        if (userId == null) {
            return Result.error(401, "未登录");
        }
        return userRepository.findById(userId)
                .map(Result::success)
                .orElse(Result.error(404, "用户不存在"));
    }

    /**
     * 更新用户信息（昵称、头像）
     */
    @PutMapping("/info")
    public Result<User> updateUserInfo(@RequestBody Map<String, String> body, HttpServletRequest request) {
        String userId = (String) request.getAttribute("userId");
        if (userId == null) {
            return Result.error(401, "未登录");
        }
        return userRepository.findById(userId).map(user -> {
            if (body.containsKey("nickname")) {
                user.setNickname(body.get("nickname"));
            }
            if (body.containsKey("avatar")) {
                user.setAvatar(body.get("avatar"));
            }
            user.setUpdatedAt(System.currentTimeMillis());
            userRepository.save(user);
            return Result.success(user);
        }).orElse(Result.error(404, "用户不存在"));
    }
}
