import { DatabaseHelper } from '../../database/helper/DatabaseHelper';
import { CloudDBProduct } from '../../database/schema/CloudDBTypes';
import { Product, ProductSpec } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'ProductService';

export class ProductService {
  private static instance: ProductService | null = null;
  private dbHelper: DatabaseHelper;

  private constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  static getInstance(): ProductService {
    if (!ProductService.instance) {
      ProductService.instance = new ProductService();
    }
    return ProductService.instance;
  }

  private convertToProduct(cloudProduct: CloudDBProduct): Product {
    return {
      productId: cloudProduct.productId || '',
      name: cloudProduct.name || '',
      description: cloudProduct.description || '',
      price: cloudProduct.price || 0,
      originalPrice: cloudProduct.originalPrice,
      stock: cloudProduct.stock || 0,
      images: cloudProduct.images ? JSON.parse(cloudProduct.images as string) as string[] : [],
      brand: cloudProduct.brand || '',
      categoryId: cloudProduct.categoryId || '',
      rating: cloudProduct.rating || 0,
      salesCount: cloudProduct.salesCount || 0,
      specs: cloudProduct.specs ? (JSON.parse(cloudProduct.specs as string) as ProductSpec[]) : [],
      latitude: cloudProduct.latitude,
      longitude: cloudProduct.longitude,
      createdAt: cloudProduct.createdAt || Date.now()
    };
  }

  private convertToCloudProduct(product: Product): CloudDBProduct {
    const cloudProduct: CloudDBProduct = new CloudDBProduct();
    cloudProduct.productId = product.productId;
    cloudProduct.name = product.name;
    cloudProduct.description = product.description;
    cloudProduct.price = product.price;
    cloudProduct.originalPrice = product.originalPrice || 0;
    cloudProduct.stock = product.stock;
    cloudProduct.images = JSON.stringify(product.images);
    cloudProduct.brand = product.brand;
    cloudProduct.categoryId = product.categoryId;
    cloudProduct.rating = product.rating;
    cloudProduct.salesCount = product.salesCount;
    cloudProduct.specs = JSON.stringify(product.specs);
    cloudProduct.latitude = product.latitude || 0;
    cloudProduct.longitude = product.longitude || 0;
    cloudProduct.createdAt = product.createdAt;
    return cloudProduct;
  }

  async getAllProducts(): Promise<Product[]> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        const empty: Product[] = [];
        return empty;
      }
      const collection = db.collection(CloudDBProduct);
      const cloudProducts: CloudDBProduct[] = await collection.query().get();
      return cloudProducts.map((item: CloudDBProduct) => this.convertToProduct(item));
    } catch (error) {
      Logger.error(TAG, 'Failed to get all products: %{public}s', JSON.stringify(error));
      throw new Error('Failed to get all products: ' + JSON.stringify(error));
    }
  }

  async getProductsByCategory(categoryId: string): Promise<Product[]> {
    try {
      const allProducts: Product[] = await this.getAllProducts();
      return allProducts.filter((p: Product) => p.categoryId === categoryId);
    } catch (error) {
      Logger.error(TAG, 'Failed to get products by category: %{public}s', JSON.stringify(error));
      throw new Error('Failed to get products by category: ' + JSON.stringify(error));
    }
  }

  async getProductById(productId: string): Promise<Product | null> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return null;
      }
      const collection = db.collection(CloudDBProduct);
      const cloudProducts: CloudDBProduct[] = await collection.query().equalTo('productId', productId).get();
      if (cloudProducts.length > 0) {
        return this.convertToProduct(cloudProducts[0]);
      }
      return null;
    } catch (error) {
      Logger.error(TAG, 'Failed to get product by id: %{public}s', JSON.stringify(error));
      throw new Error('Failed to get product by id: ' + JSON.stringify(error));
    }
  }

  async addProduct(product: Product): Promise<void> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return;
      }
      const cloudProduct: CloudDBProduct = this.convertToCloudProduct(product);
      const collection = db.collection(CloudDBProduct);
      await collection.upsert(cloudProduct);
      Logger.info(TAG, 'Product added successfully: %{public}s', product.productId);
    } catch (error) {
      Logger.error(TAG, 'Failed to add product: %{public}s', JSON.stringify(error));
      throw new Error('Failed to add product: ' + JSON.stringify(error));
    }
  }

  async addProductsBatch(products: Product[]): Promise<void> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return;
      }
      const cloudProducts: CloudDBProduct[] = products.map((item: Product) => this.convertToCloudProduct(item));
      const collection = db.collection(CloudDBProduct);
      await collection.upsert(cloudProducts);
      Logger.info(TAG, '%{public}d products added successfully', products.length);
    } catch (error) {
      Logger.error(TAG, 'Failed to add products batch: %{public}s', JSON.stringify(error));
      throw new Error('Failed to add products batch: ' + JSON.stringify(error));
    }
  }

  async searchProducts(keyword: string): Promise<Product[]> {
    try {
      const allProducts: Product[] = await this.getAllProducts();
      const lowerKeyword: string = keyword.toLowerCase();
      return allProducts.filter((p: Product) => 
        p.name.toLowerCase().includes(lowerKeyword) || 
        p.description.toLowerCase().includes(lowerKeyword) ||
        p.brand.toLowerCase().includes(lowerKeyword)
      );
    } catch (error) {
      Logger.error(TAG, 'Failed to search products: %{public}s', JSON.stringify(error));
      throw new Error('Failed to search products: ' + JSON.stringify(error));
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
