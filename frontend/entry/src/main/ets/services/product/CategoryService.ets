import { DatabaseHelper } from '../../database/helper/DatabaseHelper';
import { CloudDBCategory } from '../../database/schema/CloudDBTypes';
import { Category } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'CategoryService';

export class CategoryService {
  private static instance: CategoryService | null = null;
  private dbHelper: DatabaseHelper;

  private constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  static getInstance(): CategoryService {
    if (!CategoryService.instance) {
      CategoryService.instance = new CategoryService();
    }
    return CategoryService.instance;
  }

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

  private convertToCloudCategory(category: Category): CloudDBCategory {
    const cloudCategory: CloudDBCategory = new CloudDBCategory();
    cloudCategory.categoryId = category.categoryId;
    cloudCategory.name = category.name;
    cloudCategory.icon = category.icon;
    cloudCategory.parentId = category.parentId;
    cloudCategory.sortOrder = category.sortOrder;
    cloudCategory.createdAt = category.createdAt;
    cloudCategory.updatedAt = category.updatedAt;
    return cloudCategory;
  }

  async getAllCategories(): Promise<Category[]> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        const empty: Category[] = [];
        return empty;
      }
      const collection = db.collection(CloudDBCategory);
      const cloudCategories: CloudDBCategory[] = await collection.query().get();
      return cloudCategories.map((item: CloudDBCategory) => this.convertToCategory(item));
    } catch (error) {
      Logger.error(TAG, 'Failed to get all categories: %{public}s', JSON.stringify(error));
      throw new Error('Failed to get all categories: ' + JSON.stringify(error));
    }
  }

  async getTopLevelCategories(): Promise<Category[]> {
    try {
      const allCategories: Category[] = await this.getAllCategories();
      return allCategories.filter((c: Category) => !c.parentId);
    } catch (error) {
      Logger.error(TAG, 'Failed to get top level categories: %{public}s', JSON.stringify(error));
      throw new Error('Failed to get top level categories: ' + JSON.stringify(error));
    }
  }

  async getChildCategories(parentId: string): Promise<Category[]> {
    try {
      const allCategories: Category[] = await this.getAllCategories();
      return allCategories.filter((c: Category) => c.parentId === parentId);
    } catch (error) {
      Logger.error(TAG, 'Failed to get child categories: %{public}s', JSON.stringify(error));
      throw new Error('Failed to get child categories: ' + JSON.stringify(error));
    }
  }

  async getCategoryById(categoryId: string): Promise<Category | null> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return null;
      }
      const collection = db.collection(CloudDBCategory);
      const cloudCategories: CloudDBCategory[] = await collection.query().equalTo('categoryId', categoryId).get();
      if (cloudCategories.length > 0) {
        return this.convertToCategory(cloudCategories[0]);
      }
      return null;
    } catch (error) {
      Logger.error(TAG, 'Failed to get category by id: %{public}s', JSON.stringify(error));
      throw new Error('Failed to get category by id: ' + JSON.stringify(error));
    }
  }

  async addCategory(category: Category): Promise<void> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return;
      }
      const cloudCategory: CloudDBCategory = this.convertToCloudCategory(category);
      const collection = db.collection(CloudDBCategory);
      await collection.upsert(cloudCategory);
      Logger.info(TAG, 'Category added successfully: %{public}s', category.categoryId);
    } catch (error) {
      Logger.error(TAG, 'Failed to add category: %{public}s', JSON.stringify(error));
      throw new Error('Failed to add category: ' + JSON.stringify(error));
    }
  }

  async addCategoriesBatch(categories: Category[]): Promise<void> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return;
      }
      const cloudCategories: CloudDBCategory[] = categories.map((item: Category) => this.convertToCloudCategory(item));
      const collection = db.collection(CloudDBCategory);
      await collection.upsert(cloudCategories);
      Logger.info(TAG, '%{public}d categories added successfully', categories.length);
    } catch (error) {
      Logger.error(TAG, 'Failed to add categories batch: %{public}s', JSON.stringify(error));
      throw new Error('Failed to add categories batch: ' + JSON.stringify(error));
    }
  }
}
