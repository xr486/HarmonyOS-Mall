
# 鸿蒙商城 - HarmonyOS Mall

基于 HarmonyOS (ArkTS) 前端 + Java (Spring Boot) 后端的电商应用，使用华为 AppGallery Connect CloudDB 作为数据存储。

## 项目结构

```
hongmen-mall/
├── frontend/                 # 鸿蒙前端（ArkTS）
│   ├── AppScope/
│   ├── entry/
│   ├── common/
│   ├── services/
│   ├── database/
│   ├── components/
│   ├── features/
│   └── pages/
├── backend/                  # Java 后端（Spring Boot）
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/hongmen/mall/
│   │   │   └── resources/
│   │   └── test/
│   └── pom.xml
└── docs/                     # 项目文档
```

## 技术栈

### 前端
- **开发语言**: ArkTS (TypeScript)
- **UI 框架**: ArkUI
- **云服务**: AppGallery Connect (CloudDB, Auth Service)
- **开发工具**: DevEco Studio
- **SDK 版本**: HarmonyOS API 12+

### 后端
- **开发语言**: Java 17
- **框架**: Spring Boot 3.2.0
- **构建工具**: Maven
- **数据库**: AppGallery Connect CloudDB

## 开发团队

- 熊锐
- 易涛
