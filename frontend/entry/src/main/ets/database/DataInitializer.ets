import { DatabaseHelper } from './helper';
import { CategoryService } from '../services/product/CategoryService';
import { ProductService } from '../services/product/ProductService';
import { TestData } from './TestData';
import { Logger } from '../common/utils/logger/Logger';

const TAG = 'DataInitializer';

export class DataInitializer {
  private static instance: DataInitializer | null = null;
  private dbHelper: DatabaseHelper;
  private isInitialized: boolean = false;

  private constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  static getInstance(): DataInitializer {
    if (!DataInitializer.instance) {
      DataInitializer.instance = new DataInitializer();
    }
    return DataInitializer.instance;
  }

  async initTestData(): Promise<void> {
    if (this.isInitialized) {
      Logger.info(TAG, 'Test data already initialized');
      return;
    }

    if (!this.dbHelper.isReady()) {
      Logger.error(TAG, 'Database not ready, cannot initialize test data');
      return;
    }

    try {
      await this.initCategories();
      await this.initProducts();
      this.isInitialized = true;
      Logger.info(TAG, 'Test data initialization completed');
    } catch (e) {
      Logger.error(TAG, 'Test data initialization failed:', (e as Error).message);
    }
  }

  private async initCategories(): Promise<void> {
    try {
      const categoryService = CategoryService.getInstance();
      const existingCategories = await categoryService.getAllCategories();

      if (existingCategories.length === 0) {
        const categories = TestData.generateCategories();
        await categoryService.addCategoriesBatch(categories);
        Logger.info(TAG, `Added ${categories.length} categories`);
      } else {
        Logger.info(TAG, `Categories already exist: ${existingCategories.length}`);
      }
    } catch (e) {
      Logger.error(TAG, 'Failed to init categories:', (e as Error).message);
    }
  }

  private async initProducts(): Promise<void> {
    try {
      const productService = ProductService.getInstance();
      const existingProducts = await productService.getAllProducts();

      if (existingProducts.length === 0) {
        const products = TestData.generateProducts();
        await productService.addProductsBatch(products);
        Logger.info(TAG, `Added ${products.length} products`);
      } else {
        Logger.info(TAG, `Products already exist: ${existingProducts.length}`);
      }
    } catch (e) {
      Logger.error(TAG, 'Failed to init products:', (e as Error).message);
    }
  }
}