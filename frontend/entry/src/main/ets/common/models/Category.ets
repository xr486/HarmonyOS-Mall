
/**
 * 商品分类数据模型
 */
export interface Category {
  /** 分类 ID */
  categoryId: string;
  /** 分类名称 */
  name: string;
  /** 分类图标 URL */
  icon: string;
  /** 父分类 ID（顶级分类为空字符串） */
  parentId: string;
  /** 排序顺序 */
  sortOrder: number;
  /** 创建时间戳 */
  createdAt: number;
  /** 更新时间戳 */
  updatedAt: number;
}
