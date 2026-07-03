import { HttpUtil, ApiResponse } from '../../common/utils/http/HttpUtil';
import { Category } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'CategoryService';

export class CategoryService {
  private static instance: CategoryService | null = null;

  private constructor() {
  }

  static getInstance(): CategoryService {
    if (!CategoryService.instance) {
      CategoryService.instance = new CategoryService();
    }
    return CategoryService.instance;
  }

  async getAllCategories(): Promise<Category[]> {
    try {
      const res: ApiResponse<Category[]> = await HttpUtil.get('/categories');
      if (res.code === 200 && res.data) {
        return res.data;
      }
      return [];
    } catch (e) {
      Logger.error(TAG, 'getAllCategories error: %{public}s', JSON.stringify(e));
      return [];
    }
  }

  async getTopLevelCategories(): Promise<Category[]> {
    try {
      const res: ApiResponse<Category[]> = await HttpUtil.get('/categories/top');
      if (res.code === 200 && res.data) {
        return res.data;
      }
      return [];
    } catch (e) {
      Logger.error(TAG, 'getTopLevelCategories error: %{public}s', JSON.stringify(e));
      return [];
    }
  }

  async getChildCategories(parentId: string): Promise<Category[]> {
    try {
      const res: ApiResponse<Category[]> = await HttpUtil.get(`/categories/${parentId}/children`);
      if (res.code === 200 && res.data) {
        return res.data;
      }
      return [];
    } catch (e) {
      Logger.error(TAG, 'getChildCategories error: %{public}s', JSON.stringify(e));
      return [];
    }
  }

  async getCategoryById(categoryId: string): Promise<Category | null> {
    try {
      const res: ApiResponse<Category> = await HttpUtil.get(`/categories/${categoryId}`);
      if (res.code === 200) {
        return res.data;
      }
      return null;
    } catch (e) {
      Logger.error(TAG, 'getCategoryById error: %{public}s', JSON.stringify(e));
      return null;
    }
  }
}
