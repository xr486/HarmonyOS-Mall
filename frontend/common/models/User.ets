
/**
 * 用户数据模型
 */
export interface User {
  /** 用户 ID */
  userId: string;
  /** 手机号码 */
  phone: string;
  /** 昵称 */
  nickname: string;
  /** 头像 URL */
  avatar: string;
  /** 华为账号 ID（可选） */
  huaweiAccount?: string;
  /** 创建时间戳 */
  createdAt: number;
  /** 更新时间戳 */
  updatedAt: number;
}
