import { HttpUtil, Logger } from '../index';
import type { LocationInfo } from './LocationManager';

const TAG = 'GeoCoder';

export interface AddressComponent {
  province: string;
  city: string;
  district: string;
  street?: string;
  streetNumber?: string;
}

export interface ReverseGeoCodeResult {
  formattedAddress: string;
  addressComponent: AddressComponent;
}

export interface GeoCodeResult {
  location: LocationInfo;
  formattedAddress: string;
}

const MOCK_ADDRESS_DATA: Record<string, AddressComponent> = {
  '30.25-120.15': {
    province: '浙江省',
    city: '杭州市',
    district: '西湖区',
    street: '文三路',
    streetNumber: '138号'
  },
  '30.26-120.16': {
    province: '浙江省',
    city: '杭州市',
    district: '拱墅区',
    street: '莫干山路',
    streetNumber: '555号'
  },
  '31.23-121.47': {
    province: '上海市',
    city: '上海市',
    district: '浦东新区',
    street: '世纪大道',
    streetNumber: '100号'
  }
};

export class GeoCoder {
  private static instance: GeoCoder;

  static getInstance(): GeoCoder {
    if (!GeoCoder.instance) {
      GeoCoder.instance = new GeoCoder();
    }
    return GeoCoder.instance;
  }

  private constructor() {
    Logger.info(TAG, 'GeoCoder initialized');
  }

  async reverseGeocode(location: LocationInfo): Promise<ReverseGeoCodeResult> {
    Logger.info(TAG, `Reverse geocoding: ${location.latitude}, ${location.longitude}`);
    try {
      const result: ReverseGeoCodeResult = {
        formattedAddress: '',
        addressComponent: {
          province: '',
          city: '',
          district: ''
        }
      };
      const key = `${location.latitude.toFixed(2)}-${location.longitude.toFixed(2)}`;
      if (MOCK_ADDRESS_DATA[key]) {
        const addr = MOCK_ADDRESS_DATA[key];
        result.addressComponent = addr;
        result.formattedAddress =
          `${addr.province}${addr.city}${addr.district}${addr.street}${addr.streetNumber}`;
      } else {
        const defaultAddr = this.generateAddressByLocation(location);
        result.addressComponent = defaultAddr;
        result.formattedAddress =
          `${defaultAddr.province}${defaultAddr.city}${defaultAddr.district}${defaultAddr.street}`;
      }
      Logger.info(TAG, `Reverse geocode result: ${result.formattedAddress}`);
      return result;
    } catch (error) {
      Logger.error(TAG, `Reverse geocode failed: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  async geocode(address: string): Promise<GeoCodeResult> {
    Logger.info(TAG, `Geocoding address: ${address}`);
    try {
      const result: GeoCodeResult = {
        location: {
          latitude: 30.25,
          longitude: 120.15
        },
        formattedAddress: address
      };
      Logger.info(TAG, `Geocode result: ${result.location.latitude}, ${result.location.longitude}`);
      return result;
    } catch (error) {
      Logger.error(TAG, `Geocode failed: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  private generateAddressByLocation(location: LocationInfo): AddressComponent {
    if (location.latitude > 30 && location.longitude > 120) {
      return {
        province: '浙江省',
        city: '杭州市',
        district: '西湖区',
        street: '文三路'
      };
    } else if (location.latitude > 31 && location.longitude > 121) {
      return {
        province: '上海市',
        city: '上海市',
        district: '浦东新区',
        street: '世纪大道'
      };
    } else {
      return {
        province: '北京市',
        city: '北京市',
        district: '朝阳区',
        street: '建国路'
      };
    }
  }
}
