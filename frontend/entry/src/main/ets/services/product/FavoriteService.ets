import { HttpUtil, ApiResponse } from '../../common/utils/http/HttpUtil';
import { FavoriteItem } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'FavoriteService';

/**
 * 收藏服务
 */
export class FavoriteService {
  private static instance: FavoriteService | null = null;

  private constructor() {
  }

  static getInstance(): FavoriteService {
    if (!FavoriteService.instance) {
      FavoriteService.instance = new FavoriteService();
    }
    return FavoriteService.instance;
  }

  /**
   * 获取收藏列表
   */
  async getFavorites(): Promise<FavoriteItem[]> {
    try {
      const res: ApiResponse<Object[]> = await HttpUtil.get('/favorites');
      if (res.code === 200 && res.data) {
        const favorites: FavoriteItem[] = [];
        for (let i: number = 0; i < res.data.length; i++) {
          const raw: Record<string, Object> = res.data[i] as Record<string, Object>;
          favorites.push({
            favoriteId: (raw['favoriteId'] as string) ?? '',
            favoritedAt: (raw['favoritedAt'] as number) ?? 0,
            productId: (raw['productId'] as string) ?? '',
            name: (raw['name'] as string) ?? '',
            price: (raw['price'] as number) ?? 0,
            images: (raw['images'] as string[]) ?? [],
            rating: (raw['rating'] as number) ?? 0,
            salesCount: (raw['salesCount'] as number) ?? 0
          })
        }
        Logger.info(TAG, 'getFavorites got %{public}d items', favorites.length);
        return favorites;
      }
      return [];
    } catch (e) {
      Logger.error(TAG, 'getFavorites error: %{public}s', JSON.stringify(e));
      return [];
    }
  }

  /**
   * 切换收藏状态
   */
  async toggleFavorite(productId: string): Promise<boolean> {
    try {
      const body: Record<string, Object> = {
        productId: productId
      };
      const res: ApiResponse<Record<string, Object>> = await HttpUtil.post('/favorites/toggle', body);
      Logger.info(TAG, 'toggleFavorite code=%{public}d', res.code);
      if (res.code === 200 && res.data) {
        return (res.data['collected'] as boolean) ?? false;
      }
      return false;
    } catch (e) {
      Logger.error(TAG, 'toggleFavorite error: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  /**
   * 检查是否已收藏
   */
  async checkFavorite(productId: string): Promise<boolean> {
    try {
      const res: ApiResponse<Record<string, Object>> = await HttpUtil.get('/favorites/check/' + productId);
      if (res.code === 200 && res.data) {
        return (res.data['collected'] as boolean) ?? false;
      }
      return false;
    } catch (e) {
      Logger.error(TAG, 'checkFavorite error: %{public}s', JSON.stringify(e));
      return false;
    }
  }
}
