
/**
 * 订单状态枚举
 */
export enum OrderStatus {
  /** 待付款 */
  PENDING_PAYMENT = 0,
  /** 待发货 */
  PENDING_SHIPMENT = 1,
  /** 待收货 */
  PENDING_RECEIPT = 2,
  /** 已完成 */
  COMPLETED = 3,
  /** 已取消 */
  CANCELLED = 4
}

/**
 * 订单项
 */
export interface OrderItem {
  /** 订单项 ID */
  itemId: string;
  /** 商品 ID */
  productId: string;
  /** 商品名称（快照） */
  productName: string;
  /** 商品图片（快照） */
  productImage: string;
  /** 商品价格（快照，分） */
  price: number;
  /** 购买数量 */
  quantity: number;
  /** 商品规格（快照） */
  spec?: string;
}

/**
 * 订单数据模型
 */
export interface Order {
  /** 订单 ID */
  orderId: string;
  /** 订单编号 */
  orderNo: string;
  /** 用户 ID */
  userId: string;
  /** 订单总金额（分） */
  totalAmount: number;
  /** 订单状态 */
  status: OrderStatus;
  /** 订单项列表 */
  items: OrderItem[];
  /** 收货地址（快照） */
  address: any;
  /** 支付信息 */
  payment?: PaymentInfo;
  /** 订单备注 */
  remark?: string;
  /** 创建时间戳 */
  createdAt: number;
  /** 支付时间戳 */
  paidAt?: number;
  /** 完成时间戳 */
  completedAt?: number;
  /** 订单过期时间戳（待付款订单自动取消） */
  expireTime: number;
}
