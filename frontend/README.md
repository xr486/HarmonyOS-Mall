
# 鸿蒙商城 - HarmonyOS Mall

基于 HarmonyOS (ArkTS) 开发的电商应用，集成华为 AppGallery Connect 云服务。

## 项目说明

本项目是一个完整的鸿蒙电商应用，包含商品浏览、搜索、购物车、订单管理、支付、推荐系统、多设备协同等功能。

## 技术栈

- **开发语言**: ArkTS (TypeScript)
- **UI 框架**: ArkUI
- **云服务**: AppGallery Connect (CloudDB, Auth Service, Cloud Functions)
- **开发工具**: DevEco Studio
- **SDK 版本**: HarmonyOS API 12+

## 项目结构

```
hongmen-mall/
├── AppScope/                 # 应用级配置
│   └── app.json5
├── entry/                    # 主模块
│   ├── src/
│   │   └── main/
│   │       ├── ets/          # ArkTS 代码
│   │       │   ├── entryability/
│   │       │   └── pages/
│   │       ├── resources/    # 资源文件
│   │       └── module.json5
├── common/                   # 公共模块
│   ├── utils/                # 工具类
│   │   ├── logger/
│   │   ├── http/
│   │   └── storage/
│   ├── models/               # 数据模型
│   └── constants/            # 常量定义
├── services/                 # 服务层
│   ├── auth/
│   ├── product/
│   ├── cart/
│   ├── order/
│   ├── payment/
│   ├── recommendation/
│   └── location/
├── database/                 # 数据层
│   ├── helper/
│   ├── models/
│   └── schema/
├── components/               # 组件
│   ├── common/
│   ├── product/
│   ├── cart/
│   └── user/
├── features/                 # 功能模块
│   ├── home/
│   ├── product/
│   ├── cart/
│   ├── order/
│   ├── user/
│   └── search/
└── pages/                    # 页面
```

## 运行指南

### 环境要求

- DevEco Studio 5.0+
- HarmonyOS SDK 12+
- Node.js 18+

### 运行步骤

1. 使用 DevEco Studio 打开本项目
2. 在终端中运行初始化脚本：
   ```powershell
   powershell -ExecutionPolicy Bypass -File install.ps1
   ```
   > 该脚本会自动安装依赖并修复 hmcore SDK 在 Windows 模拟器上的 ABI 兼容性问题。
   > 如果使用真机（arm64-v8a），可跳过此步骤，直接 `ohpm install` 即可。
3. 等待依赖同步完成
4. 连接鸿蒙设备或启动模拟器
5. 点击运行按钮

### 已知问题：模拟器 ABI 不匹配

Windows 模拟器为 **x86_64** 架构，但 `@hw-agconnect/hmcore` SDK 自带 `arm64-v8a` 的 `.so` 文件，导致安装时报错：
```
code:9568347
error: install parse native so failed.
```
运行 `install.ps1` 或 `scripts/fix-hmcore.ps1` 即可自动修复。真机部署无此问题。

### AppGallery Connect 配置

1. 在 AppGallery Connect 中创建项目
2. 开通 CloudDB、Auth Service 等服务
3. 下载 `agconnect-services.json` 并放置在项目根目录
4. 配置应用签名

## 开发团队

- 熊锐
- 易涛

## 版本历史

- v1.0.0 - 初始版本
