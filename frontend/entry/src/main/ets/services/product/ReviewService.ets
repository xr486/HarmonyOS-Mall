import { HttpUtil, ApiResponse } from '../../common/utils/http/HttpUtil';
import { Review } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'ReviewService';

/**
 * 创建评价请求体
 */
class CreateReviewBody {
  productId: string = '';
  rating: number = 0;
  content: string = '';
  userName?: string;
  constructor(productId: string, rating: number, content: string, userName?: string) {
    this.productId = productId;
    this.rating = rating;
    this.content = content;
    this.userName = userName;
  }
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
          reviews.push({
            reviewId: (raw['reviewId'] as string) ?? '',
            productId: productId,
            userId: (raw['userId'] as string) ?? '',
            userName: (raw['userName'] as string) ?? '匿名用户',
            rating: (raw['rating'] as number) ?? 5,
            content: (raw['content'] as string) ?? '',
            images: (raw['images'] as string[]) ?? [],
            createdAt: (raw['createdAt'] as number) ?? 0
          })
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
   * 提交评价
   */
  async createReview(productId: string, rating: number, content: string, userName?: string): Promise<boolean> {
    try {
      const body: CreateReviewBody = new CreateReviewBody(productId, rating, content, userName);
      const res: ApiResponse<Object> = await HttpUtil.post('/reviews', body);
      Logger.info(TAG, 'createReview code=%{public}d', res.code);
      return res.code === 200;
    } catch (e) {
      Logger.error(TAG, 'createReview error: %{public}s', JSON.stringify(e));
      return false;
    }
  }
}
