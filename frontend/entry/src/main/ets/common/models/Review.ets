/**
 * 商品评价数据模型
 */
export interface Review {
  reviewId: string;
  productId: string;
  userId: string;
  userName: string;
  rating: number;
  content: string;
  images: string[];
  orderId?: string;
  createdAt: number;
}

/**
 * 评分统计
 */
export interface ReviewStats {
  total: number;
  average: number;
  star1: number;
  star2: number;
  star3: number;
  star4: number;
  star5: number;
}

/**
 * 评价对象（用于JSON映射）
 */
export class ReviewObj {
  reviewId: string = '';
  productId: string = '';
  userId: string = '';
  userName: string = '';
  rating: number = 0;
  content: string = '';
  images: string[] = [];
  orderId?: string = '';
  createdAt: number = 0;
}
