import { HttpUtil, ApiResponse } from '../../common/utils/http/HttpUtil';
import { Product, ProductSpec } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'ProductService';

interface ProductResponse {
  productId: string;
  name: string;
  description: string;
  price: number;
  originalPrice?: number;
  stock: number;
  images?: string;
  brand: string;
  categoryId: string;
  rating: number;
  salesCount: number;
  specs?: string;
  latitude?: number;
  longitude?: number;
  createdAt: number;
}

interface ProductRequest {
  productId: string;
  name: string;
  description: string;
  price: number;
  originalPrice?: number;
  stock: number;
  images: string;
  brand: string;
  categoryId: string;
  rating: number;
  salesCount: number;
  specs: string;
  latitude?: number;
  longitude?: number;
  createdAt: number;
}

function convertToProduct(item: ProductResponse): Product {
  let imagesArray: string[] = [];
  if (item.images) {
    try {
      imagesArray = JSON.parse(item.images) as string[];
    } catch {
      imagesArray = [item.images];
    }
  }

  let specsArray: ProductSpec[] = [];
  if (item.specs) {
    try {
      specsArray = JSON.parse(item.specs) as ProductSpec[];
    } catch {
      specsArray = [];
    }
  }

  return {
    productId: item.productId,
    name: item.name,
    description: item.description,
    price: item.price,
    originalPrice: item.originalPrice,
    stock: item.stock,
    images: imagesArray,
    brand: item.brand,
    categoryId: item.categoryId,
    rating: item.rating,
    salesCount: item.salesCount,
    specs: specsArray,
    latitude: item.latitude,
    longitude: item.longitude,
    createdAt: item.createdAt
  };
}

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
      const response: ApiResponse<ProductResponse[]> = await HttpUtil.get<ProductResponse[]>('/products');
      if (response.code === 200 && response.data) {
        const result: Product[] = [];
        for (let i = 0; i < response.data.length; i++) {
          result.push(convertToProduct(response.data[i]));
        }
        return result;
      }
      return [];
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Failed to get all products: %{public}s', errMsg);
      return [];
    }
  }

  async getProductsByCategory(categoryId: string): Promise<Product[]> {
    try {
      const response: ApiResponse<ProductResponse[]> = await HttpUtil.get<ProductResponse[]>(`/products/category/${categoryId}`);
      if (response.code === 200 && response.data) {
        const result: Product[] = [];
        for (let i = 0; i < response.data.length; i++) {
          result.push(convertToProduct(response.data[i]));
        }
        return result;
      }
      return [];
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Failed to get products by category: %{public}s', errMsg);
      return [];
    }
  }

  async getProductById(productId: string): Promise<Product | null> {
    try {
      const response: ApiResponse<ProductResponse> = await HttpUtil.get<ProductResponse>(`/products/${productId}`);
      if (response.code === 200 && response.data) {
        return convertToProduct(response.data);
      }
      return null;
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Failed to get product by id: %{public}s', errMsg);
      return null;
    }
  }

  async addProduct(product: Product): Promise<void> {
    try {
      const req: ProductRequest = {
        productId: product.productId,
        name: product.name,
        description: product.description,
        price: product.price,
        originalPrice: product.originalPrice,
        stock: product.stock,
        images: JSON.stringify(product.images),
        brand: product.brand,
        categoryId: product.categoryId,
        rating: product.rating,
        salesCount: product.salesCount,
        specs: JSON.stringify(product.specs),
        latitude: product.latitude,
        longitude: product.longitude,
        createdAt: product.createdAt
      };
      await HttpUtil.post<object>('/products', req);
      Logger.info(TAG, 'Product added successfully: %{public}s', product.productId);
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Failed to add product: %{public}s', errMsg);
      throw new Error('Failed to add product: ' + errMsg);
    }
  }

  async addProductsBatch(products: Product[]): Promise<void> {
    try {
      const reqList: ProductRequest[] = [];
      for (let i = 0; i < products.length; i++) {
        const item: Product = products[i];
        reqList.push({
          productId: item.productId,
          name: item.name,
          description: item.description,
          price: item.price,
          originalPrice: item.originalPrice,
          stock: item.stock,
          images: JSON.stringify(item.images),
          brand: item.brand,
          categoryId: item.categoryId,
          rating: item.rating,
          salesCount: item.salesCount,
          specs: JSON.stringify(item.specs),
          latitude: item.latitude,
          longitude: item.longitude,
          createdAt: item.createdAt
        });
      }
      await HttpUtil.post<object>('/products/batch', reqList);
      Logger.info(TAG, '%{public}d products added successfully', products.length);
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Failed to add products batch: %{public}s', errMsg);
      throw new Error('Failed to add products batch: ' + errMsg);
    }
  }

  async searchProducts(keyword: string): Promise<Product[]> {
    try {
      const response: ApiResponse<ProductResponse[]> = await HttpUtil.get<ProductResponse[]>(`/products/search?keyword=${encodeURIComponent(keyword)}`);
      if (response.code === 200 && response.data) {
        const result: Product[] = [];
        for (let i = 0; i < response.data.length; i++) {
          result.push(convertToProduct(response.data[i]));
        }
        return result;
      }
      return [];
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Failed to search products: %{public}s', errMsg);
      return [];
    }
  }
}
