import { HttpUtil, ApiResponse } from '../../common/utils/http/HttpUtil';
import { Product } from '../../common/models/Product';
import { Logger } from '../../common/utils/logger/Logger';
import { ProductService, ProductResponse, convertToProduct } from './ProductService';

const TAG = 'HomepageService';

export class HomepageService {
  private static instance: HomepageService | null = null;

  static getInstance(): HomepageService {
    if (!HomepageService.instance) {
      HomepageService.instance = new HomepageService();
    }
    return HomepageService.instance;
  }

  async getHomepageRecommendations(userId: string): Promise<Product[]> {
    try {
      const response: ApiResponse<ProductResponse[]> = await HttpUtil.get<ProductResponse[]>(
        `/homepage/recommendations?userId=${userId}`
      );
      if (response.code === 200 && response.data) {
        const result: Product[] = [];
        for (let i = 0; i < response.data.length; i++) {
          result.push(convertToProduct(response.data[i]));
        }
        return result;
      }
    } catch (e) {
      Logger.error(TAG, '获取首页推荐失败');
    }
    return [];
  }

  async getHotProducts(count: number): Promise<Product[]> {
    try {
      const prodService: ProductService = ProductService.getInstance();
      const allProducts: Product[] = await prodService.getAllProducts();
      return allProducts
        .sort((a: Product, b: Product) => b.salesCount - a.salesCount)
        .slice(0, count);
    } catch (e) {
      Logger.error(TAG, '获取热门商品失败');
      return [];
    }
  }
}
