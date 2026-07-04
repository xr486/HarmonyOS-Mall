import { HttpUtil, Logger } from '../index';
import type { LocationInfo } from './LocationManager';

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
    Logger.info(TAG, `Getting nearby products: ${request.latitude}, ${request.longitude}`);
    try {
      const response = await HttpUtil.post<Object>('/location/nearby/products', {
        latitude: request.latitude,
        longitude: request.longitude,
        radius: request.radius || 50,
        limit: request.limit || 20
      });
      if (response.code === 0 && response.data) {
        const products = response.data as Array<Record<string, Object>>;
        return products.map((item: Record<string, Object>) => ({
          productId: (item.product as Record<string, string>).productId as string,
          name: (item.product as Record<string, string>).name as string,
          price: (item.product as Record<string, number>).price as number,
          images: (item.product as Record<string, string>).images as string,
          distance: item.distance as number,
          distanceText: item.distanceText as string
        }));
      }
      return [];
    } catch (error) {
      Logger.error(TAG, `Get nearby products failed: ${JSON.stringify(error)}`);
      return [];
    }
  }

  sortByDistance<T extends { distance?: number }>(items: T[]): T[] {
    return items.sort((a, b) => (a.distance || 0) - (b.distance || 0));
  }
}
