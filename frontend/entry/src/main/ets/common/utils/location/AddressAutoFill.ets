import { LocationManager, LocationInfo } from './LocationManager';
import { GeoCoder, AddressComponent } from './GeoCoder';
import { Logger } from '../logger/Logger';

const TAG = 'AddressAutoFill';

export interface AutoFillResult {
  success: boolean;
  address?: AddressComponent;
  location?: LocationInfo;
  error?: string;
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

  async fillFromCurrentLocation(): Promise<AutoFillResult> {
    Logger.info(TAG, 'Auto fill from current location');
    try {
      const location: LocationInfo = await LocationManager.getInstance().getCurrentLocation();
      const geoResult = await GeoCoder.getInstance().reverseGeocode(location);
      Logger.info(TAG, `Auto fill success: ${geoResult.formattedAddress}`);
      return {
        success: true,
        address: geoResult.addressComponent,
        location: location
      };
    } catch (error) {
      Logger.error(TAG, `Auto fill failed: ${JSON.stringify(error)}`);
      return { success: false, error: '定位失败，请检查权限或网络' };
    }
  }
}
