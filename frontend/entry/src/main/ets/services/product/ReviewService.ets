import { HttpUtil, ApiResponse } from '../../common/utils/http/HttpUtil';
import { Review, ReviewStats, ReviewObj } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'ReviewService';

/**
 * 创建评价请求体
 */
class CreateReviewBody {
  productId: string = '';
  rating: number = 0;
  content: string = '';
  userName: string = '';
  orderId: string = '';
  orderItemId: string = '';
  constructor(productId: string, rating: number, content: string, orderId?: string, orderItemId?: string, userName?: string) {
    this.productId = productId;
    this.rating = rating;
    this.content = content;
    this.userName = userName ?? '匿名用户';
    this.orderId = orderId ?? '';
    this.orderItemId = orderItemId ?? '';
  }
}

/**
 * 评分统计对象
 */
class ReviewStatsObj {
  total: number = 0;
  average: number = 0;
  star1: number = 0;
  star2: number = 0;
  star3: number = 0;
  star4: number = 0;
  star5: number = 0;
}

/**
 * 评价服务
 */
export class ReviewService {
  private static instance: ReviewService | null = null;

  private constructor() {
  }

  static getInstance(): ReviewService {
    if (!ReviewService.instance) {
      ReviewService.instance = new ReviewService();
    }
    return ReviewService.instance;
  }

  /**
   * 获取商品评价列表
   */
  async getProductReviews(productId: string): Promise<Review[]> {
    try {
      const res: ApiResponse<Object[]> = await HttpUtil.get('/reviews/product/' + productId);
      if (res.code === 200 && res.data) {
        const reviews: Review[] = [];
        for (let i: number = 0; i < res.data.length; i++) {
          const raw: Record<string, Object> = res.data[i] as Record<string, Object>;
          const rv: ReviewObj = new ReviewObj();
          rv.reviewId = (raw['reviewId'] as string) ?? '';
          rv.productId = productId;
          rv.userId = (raw['userId'] as string) ?? '';
          rv.userName = (raw['userName'] as string) ?? '匿名用户';
          rv.rating = (raw['rating'] as number) ?? 5;
          rv.content = (raw['content'] as string) ?? '';
          rv.images = (raw['images'] as string[]) ?? [];
          rv.orderId = (raw['orderId'] as string) ?? '';
          rv.createdAt = (raw['createdAt'] as number) ?? 0;
          reviews.push(rv as Review);
        }
        Logger.info(TAG, 'getProductReviews got %{public}d reviews', reviews.length);
        return reviews;
      }
      return [];
    } catch (e) {
      Logger.error(TAG, 'getProductReviews error: %{public}s', JSON.stringify(e));
      return [];
    }
  }

  /**
   * 获取评分统计
   */
  async getReviewStats(productId: string): Promise<ReviewStats | null> {
    try {
      const res: ApiResponse<Record<string, Object>> = await HttpUtil.get('/reviews/stats/' + productId);
      if (res.code === 200 && res.data) {
        const stats: ReviewStatsObj = new ReviewStatsObj();
        stats.total = (res.data['total'] as number) ?? 0;
        stats.average = (res.data['average'] as number) ?? 0;
        stats.star1 = (res.data['star1'] as number) ?? 0;
        stats.star2 = (res.data['star2'] as number) ?? 0;
        stats.star3 = (res.data['star3'] as number) ?? 0;
        stats.star4 = (res.data['star4'] as number) ?? 0;
        stats.star5 = (res.data['star5'] as number) ?? 0;
        return stats as ReviewStats;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /**
   * 提交评价（支持订单关联）
   */
  async createReview(productId: string, rating: number, content: string, orderId?: string, orderItemId?: string): Promise<boolean> {
    try {
      const body: CreateReviewBody = new CreateReviewBody(productId, rating, content, orderId, orderItemId);
      const res: ApiResponse<Object> = await HttpUtil.post('/reviews', body);
      Logger.info(TAG, 'createReview code=%{public}d', res.code);
      return res.code === 200;
    } catch (e) {
      Logger.error(TAG, 'createReview error: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  /**
   * 检查是否已评价
   */
  async checkReviewed(productId: string, orderId: string): Promise<boolean> {
    try {
      const url: string = '/reviews/check?productId=' + encodeURIComponent(productId) +
        '&orderId=' + encodeURIComponent(orderId);
      const res: ApiResponse<Record<string, Object>> = await HttpUtil.get(url);
      if (res.code === 200 && res.data) {
        return (res.data['reviewed'] as boolean) ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
