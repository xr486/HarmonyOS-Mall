import { LocationManager, GeoCoder, Logger } from '../index';
import type { LocationInfo, AddressComponent } from '../index';

const TAG = 'AddressAutoFill';

export interface AutoFillResult {
  success: boolean;
  address?: AddressComponent;
  location?: LocationInfo;
}

export class AddressAutoFill {
  private static instance: AddressAutoFill;

  static getInstance(): AddressAutoFill {
    if (!AddressAutoFill.instance) {
      AddressAutoFill.instance = new AddressAutoFill();
    }
    return AddressAutoFill.instance;
  }

  private constructor() {
    Logger.info(TAG, 'AddressAutoFill initialized');
  }

  async autoFillCurrentLocation(): Promise<AutoFillResult> {
    Logger.info(TAG, 'Starting auto fill by current location');
    try {
      const location = await LocationManager.getInstance().getCurrentLocation();
      const geoResult = await GeoCoder.getInstance().reverseGeocode(location);
      Logger.info(TAG, `Auto fill success: ${geoResult.formattedAddress}`);
      return {
        success: true,
        address: geoResult.addressComponent,
        location: location
      };
    } catch (error) {
      Logger.error(TAG, `Auto fill failed: ${JSON.stringify(error)}`);
      return {
        success: false
      };
    }
  }

  async autoFillByLocation(location: LocationInfo): Promise<AutoFillResult> {
    Logger.info(TAG, `Auto fill by location: ${location.latitude}, ${location.longitude}`);
    try {
      const geoResult = await GeoCoder.getInstance().reverseGeocode(location);
      return {
        success: true,
        address: geoResult.addressComponent,
        location: location
      };
    } catch (error) {
      Logger.error(TAG, `Auto fill by location failed: ${JSON.stringify(error)}`);
      return {
        success: false
      };
    }
  }

  suggestKeywords(keyword: string): string[] {
    const suggestions: string[] = [];
    const keywords = ['小区', '大厦', '广场', '花园', '公寓', '路', '街', '巷'];
    for (const kw of keywords) {
      if (keyword.includes(kw)) {
        suggestions.push(keyword);
      } else {
        suggestions.push(keyword + kw);
      }
    }
    return suggestions.slice(0, 5);
  }
}
