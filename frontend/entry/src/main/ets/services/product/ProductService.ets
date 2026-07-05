import { HttpUtil, ApiResponse } from '../../common/utils/http/HttpUtil';
import { Product } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'ProductService';

export class ProductService {
  private static instance: ProductService | null = null;

  private constructor() {
  }

  static getInstance(): ProductService {
    if (!ProductService.instance) {
      ProductService.instance = new ProductService();
    }
    return ProductService.instance;
  }

  async getAllProducts(): Promise<Product[]> {
    try {
      const res: ApiResponse<Product[]> = await HttpUtil.get('/products');
      if (res.code === 200 && res.data) {
        return res.data;
      }
      return [];
    } catch (e) {
      Logger.error(TAG, 'getAllProducts error: %{public}s', JSON.stringify(e));
      return [];
    }
  }

  async getProductsByCategory(categoryId: string): Promise<Product[]> {
    try {
      const res: ApiResponse<Product[]> = await HttpUtil.get('/products/category/' + categoryId);
      if (res.code === 200 && res.data) {
        return res.data;
      }
      return [];
    } catch (e) {
      Logger.error(TAG, 'getProductsByCategory error: %{public}s', JSON.stringify(e));
      return [];
    }
  }

  async getProductById(productId: string): Promise<Product | null> {
    try {
      const res: ApiResponse<Product> = await HttpUtil.get('/products/' + productId);
      if (res.code === 200) {
        return res.data;
      }
      return null;
    } catch (e) {
      Logger.error(TAG, 'getProductById error: %{public}s', JSON.stringify(e));
      return null;
    }
  }

  async searchProducts(keyword: string): Promise<Product[]> {
    try {
      const url: string = '/products/search?keyword=' + encodeURIComponent(keyword);
      const res: ApiResponse<Product[]> = await HttpUtil.get(url);
      if (res.code === 200 && res.data) {
        return res.data;
      }
      return [];
    } catch (e) {
      Logger.error(TAG, 'searchProducts error: %{public}s', JSON.stringify(e));
      return [];
    }
  }

  async searchSuggestions(keyword: string, limit: number = 5): Promise<Product[]> {
    try {
      const url: string =
        '/products/search?keyword=' + encodeURIComponent(keyword) + '&limit=' + limit;
      const res: ApiResponse<Product[]> = await HttpUtil.get(url);
      if (res.code === 200 && res.data) {
        return res.data.slice(0, limit);
      }
      return [];
    } catch (e) {
      Logger.error(TAG, 'searchSuggestions error: %{public}s', JSON.stringify(e));
      return [];
    }
  }
}
