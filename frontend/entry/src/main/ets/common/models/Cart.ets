
/**
 * 购物车项数据模型
 * 注意：后端实体使用 checked 字段，前端兼容 selected 和 checked 两种命名
 */
export interface CartItem {
  /** 购物车项 ID */
  cartId: string;
  /** 用户 ID */
  userId: string;
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
  /** 是否选中（与后端 checked 字段对应） */
  selected: boolean;
  /** 后端返回的原始选中状态（优先级高于 selected） */
  checked?: boolean;
  /** 库存（用于限制数量） */
  stock?: number;
  /** 规格信息 */
  specs?: string;
  /** 创建时间戳 */
  createdAt?: number;
  /** 更新时间戳 */
  updatedAt?: number;
  /** 添加时间戳（前端本地用） */
  addedAt?: number;
}
