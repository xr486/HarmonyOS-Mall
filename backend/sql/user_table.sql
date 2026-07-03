-- 用户表
CREATE TABLE `user` (
  `user_id` VARCHAR(64) NOT NULL COMMENT '用户ID',
  `phone` VARCHAR(20) NOT NULL COMMENT '手机号',
  `password` VARCHAR(200) COMMENT '密码(BCrypt加密)',
  `nickname` VARCHAR(50) COMMENT '昵称',
  `avatar` VARCHAR(500) COMMENT '头像URL',
  `created_at` BIGINT NOT NULL COMMENT '创建时间(毫秒时间戳)',
  `updated_at` BIGINT NOT NULL COMMENT '更新时间(毫秒时间戳)',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';