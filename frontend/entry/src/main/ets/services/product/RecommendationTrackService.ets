import { http } from '@kit.NetworkKit';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'RecommendationTrackService';
const BASE_URL = 'http://10.0.2.2:8080/api/v1/recommendation';

export class RecommendationTrackService {
  private static instance: RecommendationTrackService | null = null;

  static getInstance(): RecommendationTrackService {
    if (!RecommendationTrackService.instance) {
      RecommendationTrackService.instance = new RecommendationTrackService();
    }
    return RecommendationTrackService.instance;
  }

  private async sendTrack(endpoint: string, productId: string, recType: string,
                          rankPosition: number | undefined, sourcePage: string, userId: string): Promise<void> {
    let req: http.HttpRequest | null = null;
    try {
      req = http.createHttp();
      let url: string = `${BASE_URL}${endpoint}?productId=${productId}&recType=${recType}&sourcePage=${sourcePage}`;
      if (rankPosition !== undefined) {
        url += `&rankPosition=${rankPosition}`;
      }
      await req.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'X-User-Id': userId
        }
      });
    } catch (e) {
      Logger.error(TAG, '追踪上报失败');
    } finally {
      if (req) {
        req.destroy();
      }
    }
  }

  async trackClick(productId: string, recType: string = 'hot', rankPosition?: number, sourcePage: string = 'homepage', userId: string = 'default_user'): Promise<void> {
    await this.sendTrack('/track/click', productId, recType, rankPosition, sourcePage, userId);
  }

  async trackConversion(productId: string, recType: string = 'hot', rankPosition?: number, sourcePage: string = 'homepage', userId: string = 'default_user'): Promise<void> {
    await this.sendTrack('/track/conversion', productId, recType, rankPosition, sourcePage, userId);
  }
}
