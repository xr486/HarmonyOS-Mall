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
  createdAt: number;
}
