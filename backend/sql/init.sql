-- ============================================================
-- 鸿蒙商城 MySQL 建库建表脚本
-- 主库 MySQL，CloudDB 仅做端侧缓存
-- ============================================================

CREATE DATABASE IF NOT EXISTS hongmen_mall
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE hongmen_mall;

-- ----------------------------
-- 1. 用户表
-- ----------------------------
CREATE TABLE `user` (
  `user_id` VARCHAR(64) NOT NULL COMMENT '用户ID',
  `phone` VARCHAR(20) NOT NULL COMMENT '手机号',
  `password` VARCHAR(200) COMMENT '密码(SHA256加密)',
  `nickname` VARCHAR(50) COMMENT '昵称',
  `avatar` VARCHAR(500) COMMENT '头像URL',
  `created_at` BIGINT NOT NULL COMMENT '创建时间(毫秒时间戳)',
  `updated_at` BIGINT NOT NULL COMMENT '更新时间(毫秒时间戳)',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ----------------------------
-- 2. 分类表
-- ----------------------------
CREATE TABLE `category` (
  `category_id` VARCHAR(64) NOT NULL COMMENT '分类ID',
  `name` VARCHAR(100) NOT NULL COMMENT '分类名称',
  `icon` VARCHAR(500) COMMENT '图标URL',
  `parent_id` VARCHAR(64) COMMENT '父分类ID',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `created_at` BIGINT NOT NULL COMMENT '创建时间',
  `updated_at` BIGINT NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`category_id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品分类表';

-- ----------------------------
-- 3. 商品表
-- ----------------------------
CREATE TABLE `product` (
  `product_id` VARCHAR(64) NOT NULL COMMENT '商品ID',
  `name` VARCHAR(200) NOT NULL COMMENT '商品名称',
  `description` TEXT COMMENT '商品描述',
  `price` DECIMAL(10,2) NOT NULL COMMENT '价格',
  `original_price` DECIMAL(10,2) COMMENT '原价',
  `stock` INT DEFAULT 0 COMMENT '库存',
  `image` VARCHAR(500) COMMENT '主图URL',
  `images` TEXT COMMENT '图片列表(JSON数组)',
  `brand` VARCHAR(100) COMMENT '品牌',
  `category_id` VARCHAR(64) COMMENT '分类ID',
  `rating` DECIMAL(2,1) DEFAULT 0 COMMENT '评分',
  `sales_count` INT DEFAULT 0 COMMENT '销量',
  `specs` TEXT COMMENT '规格参数(JSON)',
  `latitude` DOUBLE COMMENT '纬度',
  `longitude` DOUBLE COMMENT '经度',
  `created_at` BIGINT NOT NULL COMMENT '创建时间',
  `updated_at` BIGINT NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`product_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_name` (`name`),
  FULLTEXT KEY `ft_name_desc` (`name`, `description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品表';

-- ----------------------------
-- 4. 收货地址表
-- ----------------------------
CREATE TABLE `address` (
  `address_id` VARCHAR(64) NOT NULL COMMENT '地址ID',
  `user_id` VARCHAR(64) NOT NULL COMMENT '用户ID',
  `name` VARCHAR(50) NOT NULL COMMENT '收货人',
  `phone` VARCHAR(20) NOT NULL COMMENT '联系电话',
  `province` VARCHAR(50) NOT NULL COMMENT '省',
  `city` VARCHAR(50) NOT NULL COMMENT '市',
  `district` VARCHAR(50) NOT NULL COMMENT '区',
  `detail` VARCHAR(200) NOT NULL COMMENT '详细地址',
  `is_default` TINYINT(1) DEFAULT 0 COMMENT '是否默认',
  `created_at` BIGINT NOT NULL COMMENT '创建时间',
  `updated_at` BIGINT NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`address_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收货地址表';

-- ----------------------------
-- 5. 订单表
-- ----------------------------
CREATE TABLE `order_info` (
  `order_id` VARCHAR(64) NOT NULL COMMENT '订单ID',
  `user_id` VARCHAR(64) NOT NULL COMMENT '用户ID',
  `order_no` VARCHAR(32) NOT NULL COMMENT '订单编号',
  `total_amount` DECIMAL(10,2) NOT NULL COMMENT '总金额',
  `status` VARCHAR(20) NOT NULL DEFAULT 'pending_payment' COMMENT '订单状态',
  `address_id` VARCHAR(64) COMMENT '收货地址ID',
  `address_snapshot` TEXT COMMENT '地址快照',
  `remark` VARCHAR(500) COMMENT '备注',
  `created_at` BIGINT NOT NULL COMMENT '创建时间',
  `updated_at` BIGINT NOT NULL COMMENT '更新时间',
  `paid_at` BIGINT COMMENT '支付时间',
  `completed_at` BIGINT COMMENT '完成时间',
  `expire_time` BIGINT COMMENT '支付截止时间',
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

-- ----------------------------
-- 6. 订单明细表
-- ----------------------------
CREATE TABLE `order_item` (
  `item_id` VARCHAR(64) NOT NULL COMMENT '明细ID',
  `order_id` VARCHAR(64) NOT NULL COMMENT '订单ID',
  `product_id` VARCHAR(64) NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(200) COMMENT '商品名称(快照)',
  `product_image` VARCHAR(500) COMMENT '商品图片(快照)',
  `price` DECIMAL(10,2) NOT NULL COMMENT '单价',
  `quantity` INT NOT NULL DEFAULT 1 COMMENT '数量',
  `specs` VARCHAR(200) COMMENT '规格(快照)',
  PRIMARY KEY (`item_id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单明细表';

-- ----------------------------
-- 7. 购物车表
-- ----------------------------
CREATE TABLE `cart_item` (
  `cart_id` VARCHAR(64) NOT NULL COMMENT '购物车ID',
  `user_id` VARCHAR(64) NOT NULL COMMENT '用户ID',
  `product_id` VARCHAR(64) NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(200) COMMENT '商品名称(冗余)',
  `product_image` VARCHAR(500) COMMENT '商品图片(冗余)',
  `price` DECIMAL(10,2) NOT NULL COMMENT '单价',
  `quantity` INT NOT NULL DEFAULT 1 COMMENT '数量',
  `specs` VARCHAR(200) COMMENT '规格',
  `checked` TINYINT(1) DEFAULT 1 COMMENT '是否选中',
  `created_at` BIGINT NOT NULL COMMENT '创建时间',
  `updated_at` BIGINT NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`cart_id`),
  KEY `idx_user_id` (`user_id`),
  UNIQUE KEY `uk_user_product_specs` (`user_id`, `product_id`, `specs`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='购物车表';

-- ----------------------------
-- 8. 支付流水表
-- ----------------------------
CREATE TABLE `payment` (
  `payment_id` VARCHAR(64) NOT NULL COMMENT '支付ID',
  `order_id` VARCHAR(64) NOT NULL COMMENT '订单ID',
  `user_id` VARCHAR(64) NOT NULL COMMENT '用户ID',
  `amount` DECIMAL(10,2) NOT NULL COMMENT '支付金额',
  `method` VARCHAR(20) NOT NULL COMMENT '支付方式(wechat/alipay/huawei)',
  `status` VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '支付状态',
  `transaction_no` VARCHAR(64) COMMENT '第三方交易号',
  `paid_at` BIGINT COMMENT '支付时间',
  `created_at` BIGINT NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`payment_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付流水表';

-- ============================================================
-- 初始测试数据
-- ============================================================

INSERT INTO `category` VALUES 
('cat-1', '手机数码', NULL, NULL, 1, UNIX_TIMESTAMP()*1000, UNIX_TIMESTAMP()*1000),
('cat-2', '电脑办公', NULL, NULL, 2, UNIX_TIMESTAMP()*1000, UNIX_TIMESTAMP()*1000),
('cat-3', '家用电器', NULL, NULL, 3, UNIX_TIMESTAMP()*1000, UNIX_TIMESTAMP()*1000),
('cat-4', '服饰鞋包', NULL, NULL, 4, UNIX_TIMESTAMP()*1000, UNIX_TIMESTAMP()*1000),
('cat-1-1', '智能手机', NULL, 'cat-1', 1, UNIX_TIMESTAMP()*1000, UNIX_TIMESTAMP()*1000),
('cat-1-2', '智能手表', NULL, 'cat-1', 2, UNIX_TIMESTAMP()*1000, UNIX_TIMESTAMP()*1000),
('cat-3-1', '空调', NULL, 'cat-3', 1, UNIX_TIMESTAMP()*1000, UNIX_TIMESTAMP()*1000),
('cat-3-2', '冰箱', NULL, 'cat-3', 2, UNIX_TIMESTAMP()*1000, UNIX_TIMESTAMP()*1000);

INSERT INTO `product` VALUES 
('p-1', '华为Mate 60 Pro', '华为旗舰手机，卫星通信，昆仑玻璃', 6999.00, 7999.00, 100, 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Huawei+Mate+60+Pro+smartphone+product+photo+white+background&image_size=square', NULL, '华为', 'cat-1-1', 4.8, 9999, NULL, NULL, NULL, UNIX_TIMESTAMP()*1000, UNIX_TIMESTAMP()*1000),
('p-2', 'iPhone 15 Pro Max', 'Apple最新旗舰，A17 Pro芯片，钛金属设计', 9999.00, 10999.00, 80, 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=iPhone+15+Pro+Max+product+photo+white+background&image_size=square', NULL, '苹果', 'cat-1-1', 4.7, 8888, NULL, NULL, NULL, UNIX_TIMESTAMP()*1000, UNIX_TIMESTAMP()*1000),
('p-3', '华为Watch GT 4', '智能手表，两周长续航，健康监测', 2488.00, 2688.00, 200, 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Huawei+Watch+GT+4+smartwatch+product+photo+white+background&image_size=square', NULL, '华为', 'cat-1-2', 4.6, 5555, NULL, NULL, NULL, UNIX_TIMESTAMP()*1000, UNIX_TIMESTAMP()*1000),
('p-4', 'MacBook Pro 14', 'M3 Pro芯片，Liquid Retina XDR显示屏', 14999.00, 15999.00, 50, 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=MacBook+Pro+14+laptop+product+photo+white+background&image_size=square', NULL, '苹果', 'cat-2', 4.9, 3333, NULL, NULL, NULL, UNIX_TIMESTAMP()*1000, UNIX_TIMESTAMP()*1000),
('p-5', '格力空调 大1.5匹', '新一级能效，变频冷暖，自清洁', 3299.00, 3699.00, 150, 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Gree+air+conditioner+product+photo+white+background&image_size=square', NULL, '格力', 'cat-3-1', 4.5, 6666, NULL, NULL, NULL, UNIX_TIMESTAMP()*1000, UNIX_TIMESTAMP()*1000),
('p-6', '海尔冰箱 500L', '风冷无霜，干湿分储，智能温控', 4299.00, 4599.00, 120, 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Haier+refrigerator+product+photo+white+background&image_size=square', NULL, '海尔', 'cat-3-2', 4.6, 4444, NULL, NULL, NULL, UNIX_TIMESTAMP()*1000, UNIX_TIMESTAMP()*1000);
