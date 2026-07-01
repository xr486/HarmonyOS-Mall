import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { Logger } from '../logger/Logger';

const TAG = 'StorageUtil';
const PREFERENCES_NAME = 'HongmenMallPreferences';

export class StorageUtil {
  private static instance: StorageUtil | null = null;
  private context: common.Context | null = null;
  private preferences: preferences.Preferences | null = null;

  private constructor() {
  }

  static getInstance(): StorageUtil {
    if (!StorageUtil.instance) {
      StorageUtil.instance = new StorageUtil();
    }
    return StorageUtil.instance;
  }

  async init(context: common.Context): Promise<void> {
    this.context = context;
    try {
      this.preferences = await preferences.getPreferences(context, PREFERENCES_NAME);
      Logger.info(TAG, 'StorageUtil initialized');
    } catch (e) {
      Logger.error(TAG, 'Failed to initialize StorageUtil: %{public}s', (e as Error).message);
    }
  }

  async setString(key: string, value: string): Promise<void> {
    if (!this.preferences) {
      return;
    }
    await this.preferences.put(key, value);
    await this.preferences.flush();
  }

  async getString(key: string, defaultValue: string = ''): Promise<string> {
    if (!this.preferences) {
      return defaultValue;
    }
    return (await this.preferences.get(key, defaultValue)) as string;
  }

  async setNumber(key: string, value: number): Promise<void> {
    if (!this.preferences) {
      return;
    }
    await this.preferences.put(key, value);
    await this.preferences.flush();
  }

  async getNumber(key: string, defaultValue: number = 0): Promise<number> {
    if (!this.preferences) {
      return defaultValue;
    }
    return (await this.preferences.get(key, defaultValue)) as number;
  }

  async setBoolean(key: string, value: boolean): Promise<void> {
    if (!this.preferences) {
      return;
    }
    await this.preferences.put(key, value);
    await this.preferences.flush();
  }

  async getBoolean(key: string, defaultValue: boolean = false): Promise<boolean> {
    if (!this.preferences) {
      return defaultValue;
    }
    return (await this.preferences.get(key, defaultValue)) as boolean;
  }

  async setObject<T>(key: string, value: T): Promise<void> {
    const jsonString = JSON.stringify(value);
    await this.setString(key, jsonString);
  }

  async getObject<T>(key: string, defaultValue: T | null = null): Promise<T | null> {
    const jsonString = await this.getString(key, '');
    if (!jsonString) {
      return defaultValue;
    }
    try {
      return JSON.parse(jsonString) as T;
    } catch (e) {
      return defaultValue;
    }
  }

  async remove(key: string): Promise<void> {
    if (!this.preferences) {
      return;
    }
    await this.preferences.delete(key);
    await this.preferences.flush();
  }

  async clear(): Promise<void> {
    if (!this.preferences) {
      return;
    }
    await this.preferences.clear();
    await this.preferences.flush();
  }
}
