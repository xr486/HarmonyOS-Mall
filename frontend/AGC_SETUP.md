
# AppGallery Connect 集成指南

## 1. 创建项目和应用

1. 登录 [AppGallery Connect](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html)
2. 创建项目
3. 在项目下添加应用，填写：
   - 包名：`com.hongmen.mall`
   - 应用名称：鸿蒙商城

## 2. 开通服务

### 2.1 开通 Auth Service
1. 进入 "构建 &gt; 认证服务"
2. 点击 "立即开通"
3. 启用认证方式：
   - 手机号码
   - 华为账号

### 2.2 开通 CloudDB
1. 进入 "构建 &gt; CloudDB"
2. 点击 "立即开通"
3. 创建数据存储区

## 3. 下载配置文件

1. 在 "项目设置 &gt; 常规" 页面
2. 点击 "下载 agconnect-services.json"
3. 将文件放置在 `frontend/entry/src/main/resources/rawfile/` 目录下

## 4. 配置 SDK

### 4.1 配置项目级 oh-package.json5

在 `frontend/oh-package.json5` 中添加：

```json
{
  "name": "hongmen-mall",
  "version": "1.0.0",
  "description": "鸿蒙商城 - HarmonyOS Mall Application",
  "dependencies": {
    "@hw-agconnect/core": "^1.2.10",
    "@hw-agconnect/auth": "^1.2.10",
    "@hw-agconnect/clouddb": "^1.2.10"
  }
}
```

### 4.2 配置 module.json5

确保已添加必要的权限（已配置）。

## 5. 初始化 AGC

在 `EntryAbility.ets` 中初始化 AGC SDK。
