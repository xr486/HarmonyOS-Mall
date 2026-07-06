
/**
 * 支付方式枚举
 */
export enum PaymentMethod {
  /** 华为支付 */
  HUAWEI_PAY = 0,
  /** 支付宝 */
  ALIPAY = 1,
  /** 微信支付 */
  WECHAT_PAY = 2
}

/**
 * 支付状态枚举
 */
export enum PaymentStatus {
  /** 待支付 */
  PENDING = 0,
  /** 支付成功 */
  SUCCESS = 1,
  /** 支付失败 */
  FAILED = 2,
  /** 已退款 */
  REFUNDED = 3
}

/**
 * 支付信息
 */
export interface PaymentInfo {
  /** 支付 ID */
  paymentId: string;
  /** 订单 ID */
  orderId: string;
  /** 支付金额（分） */
  amount: number;
  /** 支付方式 */
  method: PaymentMethod;
  /** 支付方式文本 */
  methodText?: string;
  /** 支付状态 */
  status: PaymentStatus;
  /** 第三方交易号 */
  transactionId?: string;
  /** 支付时间戳 */
  paidAt?: number;
}
