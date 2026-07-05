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
  image?: string;
  images?: string;
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
      console.info(`[NearbyService] request body: ${JSON.stringify(body)}`);

      const rawResponse: ApiResponse<NearbyResponseItem[]> =
        await HttpUtil.post<NearbyResponseItem[]>('/location/nearby/products', body);

      console.info(`[NearbyService] rawResponse code: ${rawResponse?.code}`);
      console.info(`[NearbyService] rawResponse message: ${rawResponse?.message}`);

      const list: NearbyResponseItem[] = rawResponse?.data;
      console.info(`[NearbyService] data length: ${list?.length || 0}`);

      if (rawResponse && rawResponse.code === 200 && list && list.length > 0) {
        const result: NearbyProduct[] = [];
        for (let i = 0; i < list.length; i++) {
          const item: NearbyResponseItem = list[i];
          console.info(`[NearbyService] item ${i}: ${JSON.stringify(item)}`);

          const p: NearbyResponseProduct = item.product;

          let imageUrl: string = '';
          if (p.image) {
            imageUrl = p.image;
          } else if (p.images) {
            try {
              const imgArray: string[] = JSON.parse(p.images);
              imageUrl = imgArray.length > 0 ? imgArray[0] : '';
            } catch {
              imageUrl = p.images;
            }
          }

          result.push({
            productId: p.productId,
            name: p.name,
            price: p.price,
            images: imageUrl,
            distance: item.distance,
            distanceText: item.distanceText
          });
        }
        console.info(`[NearbyService] result length: ${result.length}`);
        return result;
      } else {
        console.warn(`[NearbyService] no data, code: ${rawResponse?.code}`);
        return [];
      }
    } catch (error) {
      console.error(`[NearbyService] error: ${JSON.stringify(error)}`);
      Logger.error(TAG, `Nearby products failed: ${JSON.stringify(error)}`);
      return [];
    }
  }

  sortByDistance(items: NearbyProduct[]): NearbyProduct[] {
    return items.sort((a: NearbyProduct, b: NearbyProduct): number => (a.distance || 0) - (b.distance || 0));
  }
}
