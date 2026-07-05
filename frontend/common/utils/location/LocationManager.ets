import geolocation from '@ohos.geoLocationManager';
import Logger from '../logger/Logger';

const TAG = 'LocationManager';

export interface LocationInfo {
  latitude: number;
  longitude: number;
  accuracy?: number;
  time?: number;
}

export class LocationManager {
  private static instance: LocationManager;
  private lastLocation: LocationInfo | null = null;

  static getInstance(): LocationManager {
    if (!LocationManager.instance) {
      LocationManager.instance = new LocationManager();
    }
    return LocationManager.instance;
  }

  private constructor() {
    Logger.info(TAG, 'LocationManager initialized');
  }

  async getCurrentLocation(): Promise<LocationInfo> {
    Logger.info(TAG, 'Getting current location...');
    try {
      const requestInfo: geolocation.LocationRequest = {
        priority: geolocation.LocationRequestPriority.PRIORITY_HIGH_ACCURACY,
        scenario: geolocation.LocationRequestScenario.UNSET,
        maxWaitTime: 1000,
        minTimeMsec: 1000
      };
      const location = await geolocation.getCurrentLocation(requestInfo);
      this.lastLocation = {
        latitude: location.latitude,
        longitude: location.longitude,
        accuracy: location.accuracy,
        time: location.time
      };
      Logger.info(TAG, `Location obtained: ${location.latitude}, ${location.longitude}`);
      return this.lastLocation;
    } catch (error) {
      Logger.error(TAG, `Failed to get location: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  getLastKnownLocation(): LocationInfo | null {
    return this.lastLocation;
  }

  static calculateDistance(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number
  ): number {
    const R = 6371;
    const dLat = LocationManager.toRad(lat2 - lat1);
    const dLon = LocationManager.toRad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(LocationManager.toRad(lat1)) *
        Math.cos(LocationManager.toRad(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private static toRad(degrees: number): number {
    return degrees * (Math.PI / 180);
  }
}
