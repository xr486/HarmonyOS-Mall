
/**
 * 购物车项数据模型
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
  /** 是否选中 */
  selected: boolean;
  /** 库存（用于限制数量） */
  stock: number;
  /** 添加时间戳 */
  addedAt: number;
}
