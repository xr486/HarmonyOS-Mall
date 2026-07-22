# 鸿蒙商城 - HarmonyOS Mall

基于 **HarmonyOS (ArkTS/ArkUI)** 前端 + **Java 17 (Spring Boot 3.2.0)** 后端的全栈移动电商应用，数据库使用 **MySQL**，集成华为 AppGallery Connect 云服务。

## 项目结构

```
hongmen-mall/
├── frontend/                          # 鸿蒙前端（ArkTS + ArkUI）
│   ├── AppScope/                      # 应用级配置
│   ├── entry/                         # 主模块
│   │   └── src/main/ets/
│   │       ├── entryability/          # 应用入口能力
│   │       ├── formability/           # 服务卡片能力
│   │       ├── pages/                 # 页面（23个页面）
│   │       ├── components/            # 公共组件
│   │       ├── common/                # 公共模块
│   │       │   ├── models/            # 数据模型
│   │       │   ├── utils/             # 工具类（HTTP、存储、日志、定位）
│   │       │   └── constants/         # 常量定义
│   │       ├── services/              # 服务层
│   │       │   ├── product/           # 商品服务
│   │       │   ├── cart/              # 购物车服务
│   │       │   ├── order/             # 订单服务
│   │       │   ├── payment/           # 支付服务
│   │       │   ├── auth/              # 认证服务
│   │       │   └── user/              # 用户服务
│   │       ├── database/              # 数据层（CloudDB）
│   │       └── widget/                # 桌面卡片
│   └── common/                        # 通用模型
│       └── models/                    # 跨模块数据模型
├── backend/                           # Java 后端（Spring Boot）
│   └── src/main/java/com/hongmen/mall/
│       ├── controller/                # 控制器层（14个）
│       ├── entity/                    # 实体类（14个）
│       ├── repository/                # 数据访问层（14个）
│       ├── service/                   # 业务服务层
│       ├── payment/                   # 支付模块（策略模式）
│       │   ├── strategy/              # 支付策略（支付宝/微信/华为）
│       │   ├── security/              # 支付安全（防重放）
│       │   └── config/                # 支付配置
│       ├── scheduler/                 # 定时任务
│       ├── config/                    # 全局配置
│       └── common/                    # 公共工具
└── docs/                              # 项目文档
```

## 技术栈

### 前端
| 技术 | 说明 |
|------|------|
| **开发语言** | ArkTS（基于 TypeScript） |
| **UI 框架** | ArkUI 声明式 UI |
| **云服务** | AppGallery Connect（CloudDB、Auth Service） |
| **开发工具** | DevEco Studio |
| **SDK 版本** | HarmonyOS API 12+ |

### 后端
| 技术 | 说明 |
|------|------|
| **开发语言** | Java 17 |
| **框架** | Spring Boot 3.2.0 |
| **构建工具** | Maven |
| **数据库** | MySQL 8.0（JPA ddl-auto: update 自动建表） |
| **ORM** | Spring Data JPA + Hibernate |
| **API 风格** | RESTful JSON |

## 功能模块

| 模块 | 功能描述 | 负责人 |
|------|---------|--------|
| 用户管理 | 注册、登录（密码/验证码）、个人信息管理 | 易涛 |
| 商品展示 | 分类展示、商品列表、商品详情、规格选择 | 熊锐 |
| 商品搜索 | 关键词搜索、多维筛选（价格/品牌/分类/评分）、排序 | 熊锐 |
| 购物车 | 添加商品、修改数量、选中/全选、删除 | 熊锐 |
| 订单管理 | 创建订单、订单列表/详情、取消/收货/删除、超时自动取消 | 熊锐 |
| 支付集成 | 支付宝/微信/华为支付（模拟模式）、支付安全 | 易涛 |
| 个性化推荐 | 首页推荐、猜你喜欢、基于浏览记录推荐 | 易涛 |
| 位置服务 | 附近商家、位置推荐 | 易涛 |
| 服务卡片 | 桌面服务卡片、数据刷新 | 易涛 |
| 多设备协同 | 购物车同步、浏览记录同步 | 易涛 |

## 后端 API 概览

后端提供 RESTful API，基础路径为 `/api/v1`，统一响应格式 `{code, message, data, timestamp}`。

| 模块 | 路径 | 主要接口 |
|------|------|---------|
| 商品 | `/api/v1/products` | 商品列表、分类查询、详情、搜索 |
| 分类 | `/api/v1/categories` | 分类列表 |
| 购物车 | `/api/v1/cart` | 增删改查、全选、清空 |
| 订单 | `/api/v1/orders` | 创建、列表、详情、取消、确认收货、发货、删除 |
| 支付 | `/api/v1/payment` | 发起支付、回调、查询状态 |
| 地址 | `/api/v1/addresses` | 增删改查、设为默认 |
| 用户 | `/api/v1/users` | 注册、登录、信息更新 |
| 收藏 | `/api/v1/favorites` | 收藏/取消、收藏列表 |
| 推荐 | `/api/v1/recommendations` | 首页推荐、猜你喜欢 |
| 评价 | `/api/v1/reviews` | 商品评价 |

## 快速开始

### 后端启动

1. 确保已安装 JDK 17+ 和 Maven 3.8+
2. 创建 MySQL 数据库（可自动创建）：`CREATE DATABASE IF NOT EXISTS hongmen_mall;`
3. 修改 `backend/src/main/resources/application.yml` 中的数据库连接配置
4. 进入 backend 目录，执行以下命令：
   ```bash
   mvn clean install
   mvn spring-boot:run
   ```
5. 服务启动后访问 `http://localhost:8080`，JPA 会自动创建数据库表结构

### 前端启动

1. 使用 DevEco Studio 打开 `frontend` 目录
2. 等待 ohpm 依赖同步完成
3. 在 AppGallery Connect 中创建项目，开通 CloudDB、Auth Service 等服务
4. 下载 `agconnect-services.json` 并放置在 `frontend` 根目录
5. 连接鸿蒙设备（真机）或启动模拟器
6. 点击运行按钮部署应用

> **注意**：Windows 模拟器为 x86_64 架构，若遇到 `install parse native so failed` 错误，需删除 `oh_modules/@hw-agconnect/cloud/libs/` 和 `hmcore/libs/` 中的 .so 文件，真机部署无此问题。

## 开发团队

- **熊锐** — 系统架构、商品展示、商品搜索、购物车、订单管理、数据库设计
- **易涛** — 用户管理、支付集成、个性化推荐、位置服务、服务卡片、多设备协同

## 开发规范

- **分支策略**：Git Flow（main → develop → feature/xxx）
- **提交格式**：`[模块名] 动作描述`
- **开发周期**：10天迭代（Day1-Day10）
- **远程仓库**：https://github.com/xiongRuiM/HarmonyOS-Mall