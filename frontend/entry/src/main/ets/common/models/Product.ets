
/**
 * 商品规格
 */
export interface ProductSpec {
  /** 规格名称 */
  name: string;
  /** 规格值列表 */
  values: string[];
}

/**
 * 商品数据模型
 */
export interface Product {
  /** 商品 ID */
  productId: string;
  /** 商品名称 */
  name: string;
  /** 商品描述 */
  description: string;
  /** 价格（分） */
  price: number;
  /** 原价（分），可选 */
  originalPrice?: number;
  /** 库存数量 */
  stock: number;
  /** 商品图片 URL 列表 */
  images: string[];
  /** 品牌 */
  brand: string;
  /** 分类 ID */
  categoryId: string;
  /** 评分（0-5） */
  rating: number;
  /** 销量 */
  salesCount: number;
  /** 商品规格 */
  specs: ProductSpec[];
  /** 是否收藏（仅对当前用户有效） */
  isCollected?: boolean;
  /** 纬度（用于位置推荐） */
  latitude?: number;
  /** 经度（用于位置推荐） */
  longitude?: number;
  /** 创建时间戳 */
  createdAt: number;
}
