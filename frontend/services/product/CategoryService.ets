
import { DatabaseHelper } from '../../database/helper';
import { CloudDBCategory } from '../../database/schema/CloudDBTypes';
import { Category } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'CategoryService';

/**
 * 分类服务类
 */
export class CategoryService {
  private static instance: CategoryService | null = null;
  private dbHelper: DatabaseHelper;

  private constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  /**
   * 获取单例实例
   */
  static getInstance(): CategoryService {
    if (!CategoryService.instance) {
      CategoryService.instance = new CategoryService();
    }
    return CategoryService.instance;
  }

  /**
   * 将 CloudDBCategory 转换为 Category
   */
  private convertToCategory(cloudCategory: CloudDBCategory): Category {
    return {
      categoryId: cloudCategory.categoryId || '',
      name: cloudCategory.name || '',
      icon: cloudCategory.icon || '',
      parentId: cloudCategory.parentId || '',
      sortOrder: cloudCategory.sortOrder || 0,
      createdAt: cloudCategory.createdAt || Date.now(),
      updatedAt: cloudCategory.updatedAt || Date.now()
    };
  }

  /**
   * 将 Category 转换为 CloudDBCategory
   */
  private convertToCloudCategory(category: Category): CloudDBCategory {
    const cloudCategory = new CloudDBCategory();
    cloudCategory.categoryId = category.categoryId;
    cloudCategory.name = category.name;
    cloudCategory.icon = category.icon;
    cloudCategory.parentId = category.parentId;
    cloudCategory.sortOrder = category.sortOrder;
    cloudCategory.createdAt = category.createdAt;
    cloudCategory.updatedAt = category.updatedAt;
    return cloudCategory;
  }

  /**
   * 获取所有分类
   */
  async getAllCategories(): Promise<Category[]> {
    try {
      const cloudCategories = await this.dbHelper.queryAll(CloudDBCategory);
      return cloudCategories.map(this.convertToCategory);
    } catch (error) {
      Logger.error(TAG, 'Failed to get all categories: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 获取顶级分类（parentId为空）
   */
  async getTopLevelCategories(): Promise<Category[]> {
    try {
      const allCategories = await this.getAllCategories();
      return allCategories.filter(c => !c.parentId);
    } catch (error) {
      Logger.error(TAG, 'Failed to get top level categories: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 获取子分类
   */
  async getChildCategories(parentId: string): Promise<Category[]> {
    try {
      const allCategories = await this.getAllCategories();
      return allCategories.filter(c => c.parentId === parentId);
    } catch (error) {
      Logger.error(TAG, 'Failed to get child categories: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 根据 ID 获取分类
   */
  async getCategoryById(categoryId: string): Promise<Category | null> {
    try {
      const cloudCategory = await this.dbHelper.queryById(CloudDBCategory, 'categoryId', categoryId);
      return cloudCategory ? this.convertToCategory(cloudCategory) : null;
    } catch (error) {
      Logger.error(TAG, 'Failed to get category by id: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 添加分类
   */
  async addCategory(category: Category): Promise<void> {
    try {
      const cloudCategory = this.convertToCloudCategory(category);
      await this.dbHelper.insert(cloudCategory);
      Logger.info(TAG, 'Category added successfully: %{public}s', category.categoryId);
    } catch (error) {
      Logger.error(TAG, 'Failed to add category: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 批量添加分类
   */
  async addCategoriesBatch(categories: Category[]): Promise<void> {
    try {
      const cloudCategories = categories.map(this.convertToCloudCategory);
      await this.dbHelper.insertBatch(cloudCategories);
      Logger.info(TAG, '%{public}d categories added successfully', categories.length);
    } catch (error) {
      Logger.error(TAG, 'Failed to add categories batch: %{public}s', JSON.stringify(error));
      throw error;
    }
  }
}
