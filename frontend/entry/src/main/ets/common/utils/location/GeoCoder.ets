import { Logger } from '../logger/Logger';
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
  '30.25-120.15': { province: '浙江省', city: '杭州市', district: '西湖区', street: '文三路', streetNumber: '138号' },
  '30.26-120.16': { province: '浙江省', city: '杭州市', district: '拱墅区', street: '莫干山路', streetNumber: '555号' },
  '30.24-120.14': { province: '浙江省', city: '杭州市', district: '上城区', street: '延安路', streetNumber: '202号' },
  '30.23-120.13': { province: '浙江省', city: '杭州市', district: '滨江区', street: '江南大道', streetNumber: '388号' },
  '31.23-121.47': { province: '上海市', city: '上海市', district: '浦东新区', street: '世纪大道', streetNumber: '100号' },
  '31.24-121.48': { province: '上海市', city: '上海市', district: '黄浦区', street: '南京路', streetNumber: '520号' },
  '31.22-121.43': { province: '上海市', city: '上海市', district: '徐汇区', street: '衡山路', streetNumber: '10号' },
  '23.13-113.26': { province: '广东省', city: '广州市', district: '天河区', street: '天河路', streetNumber: '385号' },
  '23.12-113.25': { province: '广东省', city: '广州市', district: '海珠区', street: '新港中路', streetNumber: '456号' },
  '22.54-113.93': { province: '广东省', city: '深圳市', district: '南山区', street: '科技园路', streetNumber: '1号' },
  '22.53-113.95': { province: '广东省', city: '深圳市', district: '福田区', street: '深南大道', streetNumber: '999号' },
  '39.90-116.40': { province: '北京市', city: '北京市', district: '朝阳区', street: '建国路', streetNumber: '88号' },
  '39.91-116.38': { province: '北京市', city: '北京市', district: '海淀区', street: '中关村大街', streetNumber: '1号' },
  '30.57-114.27': { province: '湖北省', city: '武汉市', district: '武昌区', street: '珞喻路', streetNumber: '1037号' },
  '30.58-114.30': { province: '湖北省', city: '武汉市', district: '洪山区', street: '雄楚大道', streetNumber: '666号' },
  '30.59-103.95': { province: '四川省', city: '成都市', district: '武侯区', street: '人民南路', streetNumber: '四段' },
  '32.04-118.77': { province: '江苏省', city: '南京市', district: '鼓楼区', street: '汉中路', streetNumber: '150号' },
  '25.84-114.92': { province: '江西省', city: '赣州市', district: '章贡区', street: '经济技术开发区', streetNumber: '' }
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
    const key: string = `${location.latitude.toFixed(2)}-${location.longitude.toFixed(2)}`;
    let addr: AddressComponent;
    if (MOCK_ADDRESS_DATA[key]) {
      addr = MOCK_ADDRESS_DATA[key];
    } else {
      addr = this.generateAddressByLocation(location);
    }
    const result: ReverseGeoCodeResult = {
      addressComponent: addr,
      formattedAddress: `${addr.province}${addr.city}${addr.district}${addr.street || ''}${addr.streetNumber || ''}`
    };
    Logger.info(TAG, `Result: ${result.formattedAddress}`);
    return result;
  }

  async geocode(address: string): Promise<GeoCodeResult> {
    Logger.info(TAG, `Geocoding: ${address}`);
    let lat: number = 30.254;
    let lng: number = 120.150;
    if (address.includes('北京')) { lat = 39.904; lng = 116.407; }
    if (address.includes('上海')) { lat = 31.230; lng = 121.473; }
    if (address.includes('广州')) { lat = 23.129; lng = 113.264; }
    if (address.includes('深圳')) { lat = 22.543; lng = 113.938; }
    if (address.includes('武汉')) { lat = 30.572; lng = 114.279; }
    if (address.includes('成都')) { lat = 30.595; lng = 103.951; }
    if (address.includes('南京')) { lat = 32.041; lng = 118.774; }
    return { location: { latitude: lat, longitude: lng }, formattedAddress: address };
  }

  private generateAddressByLocation(location: LocationInfo): AddressComponent {
    if (location.latitude > 31 && location.latitude < 32 &&
      location.longitude > 121 && location.longitude < 122) {
      return { province: '上海市', city: '上海市', district: '浦东新区', street: '' };
    }
    if (location.latitude > 30 && location.latitude < 31 &&
      location.longitude > 120 && location.longitude < 121) {
      return { province: '浙江省', city: '杭州市', district: '西湖区', street: '' };
    }
    if (location.latitude > 22 && location.latitude < 23 &&
      location.longitude > 113 && location.longitude < 115) {
      if (location.longitude < 113.5) {
        return { province: '广东省', city: '广州市', district: '天河区', street: '' };
      }
      return { province: '广东省', city: '深圳市', district: '南山区', street: '' };
    }
    if (location.latitude > 39 && location.latitude < 41 &&
      location.longitude > 115 && location.longitude < 118) {
      return { province: '北京市', city: '北京市', district: '朝阳区', street: '' };
    }
    if (location.latitude > 30 && location.latitude < 31 &&
      location.longitude > 103 && location.longitude < 104) {
      return { province: '四川省', city: '成都市', district: '武侯区', street: '' };
    }
    if (location.latitude > 30 && location.latitude < 31 &&
      location.longitude > 114 && location.longitude < 115) {
      return { province: '湖北省', city: '武汉市', district: '武昌区', street: '' };
    }
    if (location.latitude > 31 && location.latitude < 33 &&
      location.longitude > 118 && location.longitude < 119) {
      return { province: '江苏省', city: '南京市', district: '鼓楼区', street: '' };
    }
    if (location.latitude > 35 && location.latitude < 37 &&
      location.longitude > 120 && location.longitude < 121) {
      return { province: '山东省', city: '青岛市', district: '市南区', street: '' };
    }
    return { province: '浙江省', city: '杭州市', district: '西湖区', street: '' };
  }
}
