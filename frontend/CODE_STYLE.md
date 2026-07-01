
# 代码风格规范

## 1. 命名规范

### 1.1 文件/目录命名
- 目录名：小写，多个单词用连字符（kebab-case），如 `product-list`
- 组件文件：大写开头，多个单词用驼峰（PascalCase），如 `ProductCard.ets`
- 工具/模型文件：小写，多个单词用点或下划线，如 `http.util.ets` 或 `user.model.ets`

### 1.2 变量/函数命名
- 变量：驼峰命名法（camelCase），如 `userName`
- 常量：全大写下划线分隔（UPPER_SNAKE_CASE），如 `MAX_COUNT`
- 函数：驼峰命名法（camelCase），如 `getUserInfo`
- 组件/类：大写开头驼峰（PascalCase），如 `ProductCard`

### 1.3 接口命名
- 接口名：大写开头驼峰（PascalCase），前缀可选 `I`，如 `User` 或 `IUser`

## 2. 代码格式

### 2.1 缩进
- 使用 2 个空格缩进，不要使用 Tab
- 嵌套结构保持适当缩进

### 2.2 分号
- 语句结束必须使用分号

### 2.3 引号
- 字符串使用单引号 `'`
- 模板字符串使用反引号 `` ` ``
- 避免不必要的转义

### 2.4 大括号
- 左大括号不换行（1tbs 风格）
- 单行代码块可以省略大括号，但建议保留

## 3. TypeScript 规范

### 3.1 类型声明
- 优先使用 interface 定义对象类型
- 类型尽可能明确，避免过度使用 `any`
- 适当使用类型推断

### 3.2 变量声明
- 优先使用 `const`，需要重新赋值时使用 `let`
- 禁止使用 `var`

## 4. 注释规范

### 4.1 文件头注释
```typescript
/**
 * @file 文件名
 * @description 文件描述
 * @author 作者
 * @date 日期
 */
```

### 4.2 函数/方法注释
```typescript
/**
 * 函数描述
 * @param 参数名 参数描述
 * @returns 返回值描述
 */
```

## 5. Git 提交规范

提交信息格式：
```
<type>(<scope>): <subject>

<type>: 类型
  - feat: 新功能
  - fix: 修复bug
  - docs: 文档更新
  - style: 代码格式调整
  - refactor: 重构
  - test: 测试相关
  - chore: 构建/工具相关

<scope>: 影响范围，可选
<subject>: 简短描述，不超过50字符
```
