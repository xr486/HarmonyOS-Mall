import { HttpUtil } from '../http/HttpUtil';
import { Logger } from '../logger/Logger';

const TAG = 'NearbyService';

export interface NearbyProduct {
  productId: string;
  name: string;
  price: number;
  images: string;
  distance: number;
  distanceText: string;
}

export interface NearbyRequest {
  latitude: number;
  longitude: number;
  radius?: number;
  limit?: number;
}

interface NearbyResponseItem {
  product: NearbyResponseProduct;
  distance: number;
  distanceText: string;
}

interface NearbyResponseProduct {
  productId: string;
  name: string;
  price: number;
  image: string;
}

interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

export class NearbyService {
  private static instance: NearbyService;

  static getInstance(): NearbyService {
    if (!NearbyService.instance) {
      NearbyService.instance = new NearbyService();
    }
    return NearbyService.instance;
  }

  private constructor() {
    Logger.info(TAG, 'NearbyService initialized');
  }

  async getNearbyProducts(request: NearbyRequest): Promise<NearbyProduct[]> {
    Logger.info(TAG, `Getting nearby: ${request.latitude}, ${request.longitude}`);
    try {
      const body: NearbyRequest = {
        latitude: request.latitude,
        longitude: request.longitude,
        radius: request.radius || 50,
        limit: request.limit || 20
      };
      const rawResponse: ApiResponse<NearbyResponseItem[]> =
        await HttpUtil.post<NearbyResponseItem[]>('/location/nearby/products', body);
      if (rawResponse && rawResponse.code === 200 && rawResponse.data) {
        const list: NearbyResponseItem[] = rawResponse.data;
        const result: NearbyProduct[] = [];
        for (let i = 0; i < list.length; i++) {
          const item: NearbyResponseItem = list[i];
          const p: NearbyResponseProduct = item.product;
          result.push({
            productId: p.productId,
            name: p.name,
            price: p.price,
            images: p.image,
            distance: item.distance,
            distanceText: item.distanceText
          });
        }
        return result;
      }
      return [];
    } catch (error) {
      Logger.error(TAG, `Nearby products failed: ${JSON.stringify(error)}`);
      return [];
    }
  }

  sortByDistance(items: NearbyProduct[]): NearbyProduct[] {
    return items.sort((a: NearbyProduct, b: NearbyProduct): number => (a.distance || 0) - (b.distance || 0));
  }
}
