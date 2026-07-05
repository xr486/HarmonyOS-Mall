import { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { common } from '@kit.AbilityKit';
import { Logger } from '../logger/Logger';

const TAG = 'LocationManager';

const LOCATION_PERMISSIONS: Array<Permissions> = [
  'ohos.permission.APPROXIMATELY_LOCATION',
  'ohos.permission.LOCATION'
];

export interface LocationInfo {
  latitude: number;
  longitude: number;
  accuracy?: number;
  altitude?: number;
  time?: number;
}

export class LocationManager {
  private static instance: LocationManager;
  private lastLocation: LocationInfo | null = null;
  private permissionGranted: boolean = false;
  private context: common.UIAbilityContext | null = null;

  static getInstance(): LocationManager {
    if (!LocationManager.instance) {
      LocationManager.instance = new LocationManager();
    }
    return LocationManager.instance;
  }

  private constructor() {
    Logger.info(TAG, 'LocationManager initialized');
  }

  init(context: common.UIAbilityContext): void {
    this.context = context;
    Logger.info(TAG, 'LocationManager context set');
  }

  async requestPermission(): Promise<boolean> {
    if (!this.context) {
      Logger.error(TAG, 'Context not initialized');
      return false;
    }
    try {
      const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      const appInfo = this.context.applicationInfo;
      if (!appInfo) {
        return false;
      }
      const grantStatus: abilityAccessCtrl.GrantStatus =
        atManager.checkAccessTokenSync(appInfo.accessTokenId, 'ohos.permission.LOCATION');
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        this.permissionGranted = true;
        Logger.info(TAG, 'Location permission already granted');
        return true;
      }
      const result = await atManager.requestPermissionsFromUser(this.context, LOCATION_PERMISSIONS);
      const allGranted: boolean = result.authResults.every((r: number): boolean => r === 0);
      this.permissionGranted = allGranted;
      Logger.info(TAG, `Location permission ${allGranted ? 'granted' : 'denied'}`);
      return allGranted;
    } catch (error) {
      Logger.error(TAG, `Permission request failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  isPermissionGranted(): boolean {
    return this.permissionGranted;
  }

  async getCurrentLocation(): Promise<LocationInfo> {
    Logger.info(TAG, 'Getting current location...');
    if (!this.permissionGranted) {
      const granted: boolean = await this.requestPermission();
      if (!granted) {
        throw new Error('Location permission not granted');
      }
    }
    try {
      const requestInfo: geoLocationManager.LocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.UNSET,
        timeInterval: 1,
        maxAccuracy: 0
      };
      const location: geoLocationManager.Location =
        await geoLocationManager.getCurrentLocation(requestInfo);
      this.lastLocation = {
        latitude: location.latitude,
        longitude: location.longitude,
        accuracy: location.accuracy,
        altitude: location.altitude,
        time: location.timeStamp
      };
      Logger.info(TAG, `Location: ${location.latitude}, ${location.longitude}`);
      return this.lastLocation;
    } catch (error) {
      Logger.error(TAG, `Location failed, using default: ${JSON.stringify(error)}`);
      if (this.lastLocation) {
        return this.lastLocation;
      }
      const defaultLoc: LocationInfo = { latitude: 25.84, longitude: 114.92, accuracy: 100 };
      this.lastLocation = defaultLoc;
      return defaultLoc;
    }
  }

  getLastKnownLocation(): LocationInfo | null {
    return this.lastLocation;
  }

  static calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R: number = 6371;
    const dLat: number = LocationManager.toRad(lat2 - lat1);
    const dLon: number = LocationManager.toRad(lon2 - lon1);
    const a: number =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(LocationManager.toRad(lat1)) *
      Math.cos(LocationManager.toRad(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c: number = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  static formatDistance(km: number): string {
    if (km < 0.1) {
      return '<100m';
    }
    if (km < 1) {
      return Math.round(km * 1000) + 'm';
    }
    return km.toFixed(1) + 'km';
  }

  private static toRad(degrees: number): number {
    return degrees * (Math.PI / 180);
  }
}
