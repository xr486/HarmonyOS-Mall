
import { DatabaseHelper } from '../../database/helper';
import { CloudDBProduct } from '../../database/schema/CloudDBTypes';
import { Product, ProductSpec } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'ProductService';

/**
 * 商品服务类
 */
export class ProductService {
  private static instance: ProductService | null = null;
  private dbHelper: DatabaseHelper;

  private constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  /**
   * 获取单例实例
   */
  static getInstance(): ProductService {
    if (!ProductService.instance) {
      ProductService.instance = new ProductService();
    }
    return ProductService.instance;
  }

  /**
   * 将 CloudDBProduct 转换为 Product
   */
  private convertToProduct(cloudProduct: CloudDBProduct): Product {
    return {
      productId: cloudProduct.productId || '',
      name: cloudProduct.name || '',
      description: cloudProduct.description || '',
      price: cloudProduct.price || 0,
      originalPrice: cloudProduct.originalPrice,
      stock: cloudProduct.stock || 0,
      images: cloudProduct.images ? JSON.parse(cloudProduct.images) : [],
      brand: cloudProduct.brand || '',
      categoryId: cloudProduct.categoryId || '',
      rating: cloudProduct.rating || 0,
      salesCount: cloudProduct.salesCount || 0,
      specs: cloudProduct.specs ? JSON.parse(cloudProduct.specs) : [],
      latitude: cloudProduct.latitude,
      longitude: cloudProduct.longitude,
      createdAt: cloudProduct.createdAt || Date.now()
    };
  }

  /**
   * 将 Product 转换为 CloudDBProduct
   */
  private convertToCloudProduct(product: Product): CloudDBProduct {
    const cloudProduct = new CloudDBProduct();
    cloudProduct.productId = product.productId;
    cloudProduct.name = product.name;
    cloudProduct.description = product.description;
    cloudProduct.price = product.price;
    cloudProduct.originalPrice = product.originalPrice;
    cloudProduct.stock = product.stock;
    cloudProduct.images = JSON.stringify(product.images);
    cloudProduct.brand = product.brand;
    cloudProduct.categoryId = product.categoryId;
    cloudProduct.rating = product.rating;
    cloudProduct.salesCount = product.salesCount;
    cloudProduct.specs = JSON.stringify(product.specs);
    cloudProduct.latitude = product.latitude;
    cloudProduct.longitude = product.longitude;
    cloudProduct.createdAt = product.createdAt;
    return cloudProduct;
  }

  /**
   * 获取所有商品
   */
  async getAllProducts(): Promise<Product[]> {
    try {
      const cloudProducts = await this.dbHelper.queryAll(CloudDBProduct);
      return cloudProducts.map(this.convertToProduct);
    } catch (error) {
      Logger.error(TAG, 'Failed to get all products: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 根据分类 ID 获取商品列表
   */
  async getProductsByCategory(categoryId: string): Promise<Product[]> {
    try {
      const allProducts = await this.getAllProducts();
      return allProducts.filter(p => p.categoryId === categoryId);
    } catch (error) {
      Logger.error(TAG, 'Failed to get products by category: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 根据 ID 获取商品详情
   */
  async getProductById(productId: string): Promise<Product | null> {
    try {
      const cloudProduct = await this.dbHelper.queryById(CloudDBProduct, 'productId', productId);
      return cloudProduct ? this.convertToProduct(cloudProduct) : null;
    } catch (error) {
      Logger.error(TAG, 'Failed to get product by id: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 添加商品
   */
  async addProduct(product: Product): Promise<void> {
    try {
      const cloudProduct = this.convertToCloudProduct(product);
      await this.dbHelper.insert(cloudProduct);
      Logger.info(TAG, 'Product added successfully: %{public}s', product.productId);
    } catch (error) {
      Logger.error(TAG, 'Failed to add product: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 批量添加商品（用于预置测试数据）
   */
  async addProductsBatch(products: Product[]): Promise<void> {
    try {
      const cloudProducts = products.map(this.convertToCloudProduct);
      await this.dbHelper.insertBatch(cloudProducts);
      Logger.info(TAG, '%{public}d products added successfully', products.length);
    } catch (error) {
      Logger.error(TAG, 'Failed to add products batch: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 搜索商品
   */
  async searchProducts(keyword: string): Promise<Product[]> {
    try {
      const allProducts = await this.getAllProducts();
      const lowerKeyword = keyword.toLowerCase();
      return allProducts.filter(p => 
        p.name.toLowerCase().includes(lowerKeyword) || 
        p.description.toLowerCase().includes(lowerKeyword) ||
        p.brand.toLowerCase().includes(lowerKeyword)
      );
    } catch (error) {
      Logger.error(TAG, 'Failed to search products: %{public}s', JSON.stringify(error));
      throw error;
    }
  }
}
