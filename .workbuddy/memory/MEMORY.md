# 鸿蒙商城项目长期记忆

## 项目结构约定
- 前端主代码目录：`frontend/entry/src/main/ets/`
- 后端主代码目录：`backend/src/main/java/com/hongmen/mall/`
- 底部 Tab 购物车组件在 `Index.ets` 的 `CartTab` 中，独立 `CartPage.ets` 用于页面跳转场景
- 底部 Tab 订单组件在 `Index.ets` 的 `OrderTab` 中，独立 `OrderListPage.ets` 用于页面跳转场景

## 前后端字段映射
- 购物车选中状态：后端字段 `checked`（TINYINT），前端字段 `selected`（boolean）
- 订单状态：后端存储字符串（`pending_payment`/`pending_shipment`/`pending_receipt`/`completed`/`cancelled`），前端枚举为数字 `OrderStatus` 0-4
- 订单服务 `getAllOrders()` 需要将前端数字状态转换为后端字符串状态查询

## 代码风格
- ArkTS 严格模式下避免直接类型断言读取后端字段，建议先用 `JSON.stringify` + `JSON.parse` 得到 `Record<string, Object>` 再索引读取
- 网络请求统一走 `HttpUtil`，URL 前缀为 `http://192.168.150.1:8080/api/v1`
- Git 提交信息格式：`[模块名] 动作描述`，例如 `[订单] 修复订单列表页排版`

## Git 工作流
- 功能分支命名：`feature/模块名`
- 禁止直接向 develop/main 推送，必须通过 Pull Request 合并
- 每日至少两次提交（中午/晚间），晚间提交需创建 PR

## 常见坑点
- 鸿蒙模拟器/真机中 `localhost` 指向设备自身，需使用宿主机局域网 IP
- Checkbox 组件使用 `onClick` 避免递归触发，`onChange` 在部分场景会自循环
- `ForEach` 的 key 函数建议包含索引或状态字段，防止状态变化不刷新
