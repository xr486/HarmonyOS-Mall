package com.hongmen.mall.config;

import com.hongmen.mall.controller.AuthController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * Token 鉴权拦截器
 */
@Component
public class TokenInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        // auth 接口不需要鉴权
        String path = request.getRequestURI();
        if (path.startsWith("/api/v1/auth/")) {
            return true;
        }

        // GET 请求的商品/分类接口允许匿名访问
        if ("GET".equalsIgnoreCase(request.getMethod()) &&
            (path.startsWith("/api/v1/products") || path.startsWith("/api/v1/categories"))) {
            return true;
        }

        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            String userId = AuthController.getUserIdByToken(token);
            if (userId != null) {
                request.setAttribute("userId", userId);
                return true;
            }
        }

        response.setStatus(401);
        response.setContentType("application/json;charset=UTF-8");
        try {
            response.getWriter().write("{\"code\":401,\"message\":\"未登录或token已过期\",\"data\":null,\"timestamp\":" +
                    System.currentTimeMillis() + "}");
        } catch (Exception ignored) {
        }
        return false;
    }
}
