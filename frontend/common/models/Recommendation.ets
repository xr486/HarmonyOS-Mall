
import { Product } from './Product';

/**
 * 推荐类型
 */
export type RecommendationType = 'collaborative' | 'content' | 'location';

/**
 * 推荐项
 */
export interface RecommendationItem {
  /** 商品 */
  product: Product;
  /** 推荐类型 */
  recType: RecommendationType;
  /** 推荐得分 */
  score: number;
  /** 推荐理由 */
  reason: string;
}
