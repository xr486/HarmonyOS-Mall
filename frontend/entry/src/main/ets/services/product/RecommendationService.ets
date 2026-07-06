import { HttpUtil, ApiResponse } from '../../common/utils/http/HttpUtil';
import { Logger } from '../../common/utils/logger/Logger';
import { Product, ProductSpec, RecommendationItem, RecommendationType } from '../../common/models';

const TAG = 'RecommendationService';

interface RecommendationResponse {
  userId: string;
  productId: string;
  score: number;
  type: string;
  recRank: number;
  updatedAt: number;
}

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

function convertToProductFromResponse(item: ProductResponse): Product {
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

function convertToProduct(rec: RecommendationResponse, products: Product[]): Product | null {
  for (let i = 0; i < products.length; i++) {
    if (products[i].productId === rec.productId) {
      return products[i];
    }
  }
  return null;
}

export class RecommendationService {
  private static instance: RecommendationService | null = null;

  private constructor() {
  }

  static getInstance(): RecommendationService {
    if (!RecommendationService.instance) {
      RecommendationService.instance = new RecommendationService();
    }
    return RecommendationService.instance;
  }

  async getRecommendations(userId: string): Promise<RecommendationItem[]> {
    try {
      const response: ApiResponse<ProductResponse[]> = await HttpUtil.get<ProductResponse[]>(
        `/recommendations/user/${userId}/similar`
      );
      if (response.code === 200 && response.data) {
        const result: RecommendationItem[] = [];
        for (let i = 0; i < response.data.length; i++) {
          const product = convertToProductFromResponse(response.data[i]);
          result.push({
            product: product,
            recType: 'content',
            score: 1.0,
            reason: '同类推荐'
          });
        }
        return result;
      }
      return [];
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Failed to get recommendations: %{public}s', errMsg);
      return [];
    }
  }

  async getCollaborativeRecommendations(userId: string): Promise<RecommendationItem[]> {
    try {
      const response: ApiResponse<RecommendationResponse[]> = await HttpUtil.get<RecommendationResponse[]>(
        `/recommendations/user/${userId}/collaborative`
      );
      if (response.code === 200 && response.data) {
        const productService = (await import('./ProductService')).ProductService.getInstance();
        const allProducts: Product[] = await productService.getAllProducts();
        
        const result: RecommendationItem[] = [];
        for (let i = 0; i < response.data.length; i++) {
          const rec = response.data[i];
          const product = convertToProduct(rec, allProducts);
          if (product) {
            result.push({
              product: product,
              recType: 'collaborative',
              score: rec.score,
              reason: '猜你喜欢'
            });
          }
        }
        return result;
      }
      return [];
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Failed to get collaborative recommendations: %{public}s', errMsg);
      return [];
    }
  }

  async getContentRecommendations(userId: string): Promise<RecommendationItem[]> {
    try {
      const response: ApiResponse<RecommendationResponse[]> = await HttpUtil.get<RecommendationResponse[]>(
        `/recommendations/user/${userId}/content`
      );
      if (response.code === 200 && response.data) {
        const productService = (await import('./ProductService')).ProductService.getInstance();
        const allProducts: Product[] = await productService.getAllProducts();
        
        const result: RecommendationItem[] = [];
        for (let i = 0; i < response.data.length; i++) {
          const rec = response.data[i];
          const product = convertToProduct(rec, allProducts);
          if (product) {
            result.push({
              product: product,
              recType: 'content',
              score: rec.score,
              reason: '为你推荐'
            });
          }
        }
        return result;
      }
      return [];
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Failed to get content recommendations: %{public}s', errMsg);
      return [];
    }
  }

  async refreshRecommendations(userId: string): Promise<boolean> {
    try {
      const response: ApiResponse<object> = await HttpUtil.post<object>(
        `/recommendations/refresh/user/${userId}`
      );
      return response.code === 200;
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Failed to refresh recommendations: %{public}s', errMsg);
      return false;
    }
  }

  private getReason(type: string): string {
    switch (type) {
      case 'collaborative':
        return '猜你喜欢';
      case 'content':
        return '为你推荐';
      default:
        return '推荐';
    }
  }
}