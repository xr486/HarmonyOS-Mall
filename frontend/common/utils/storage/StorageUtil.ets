
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { Logger } from '../logger/Logger';

const TAG = 'StorageUtil';
const PREFERENCES_NAME = 'HongmenMallPreferences';

/**
 * 本地存储工具类（使用 Preferences）
 */
export class StorageUtil {
  private static instance: StorageUtil | null = null;
  private context: common.Context | null = null;
  private preferences: preferences.Preferences | null = null;

  private constructor() {}

  /**
   * 获取单例实例
   */
  static getInstance(): StorageUtil {
    if (!StorageUtil.instance) {
      StorageUtil.instance = new StorageUtil();
    }
    return StorageUtil.instance;
  }

  /**
   * 初始化
   */
  async init(context: common.Context): Promise<void> {
    this.context = context;
    try {
      this.preferences = await preferences.getPreferences(context, PREFERENCES_NAME);
      Logger.info(TAG, 'StorageUtil initialized');
    } catch (error) {
      Logger.error(TAG, 'Failed to initialize StorageUtil: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 保存字符串
   */
  async setString(key: string, value: string): Promise<void> {
    if (!this.preferences) {
      throw new Error('StorageUtil not initialized');
    }
    await this.preferences.put(key, value);
    await this.preferences.flush();
  }

  /**
   * 获取字符串
   */
  async getString(key: string, defaultValue: string = ''): Promise<string> {
    if (!this.preferences) {
      throw new Error('StorageUtil not initialized');
    }
    return (await this.preferences.get(key, defaultValue)) as string;
  }

  /**
   * 保存数字
   */
  async setNumber(key: string, value: number): Promise<void> {
    if (!this.preferences) {
      throw new Error('StorageUtil not initialized');
    }
    await this.preferences.put(key, value);
    await this.preferences.flush();
  }

  /**
   * 获取数字
   */
  async getNumber(key: string, defaultValue: number = 0): Promise<number> {
    if (!this.preferences) {
      throw new Error('StorageUtil not initialized');
    }
    return (await this.preferences.get(key, defaultValue)) as number;
  }

  /**
   * 保存布尔值
   */
  async setBoolean(key: string, value: boolean): Promise<void> {
    if (!this.preferences) {
      throw new Error('StorageUtil not initialized');
    }
    await this.preferences.put(key, value);
    await this.preferences.flush();
  }

  /**
   * 获取布尔值
   */
  async getBoolean(key: string, defaultValue: boolean = false): Promise<boolean> {
    if (!this.preferences) {
      throw new Error('StorageUtil not initialized');
    }
    return (await this.preferences.get(key, defaultValue)) as boolean;
  }

  /**
   * 保存对象
   */
  async setObject<T>(key: string, value: T): Promise<void> {
    const jsonString = JSON.stringify(value);
    await this.setString(key, jsonString);
  }

  /**
   * 获取对象
   */
  async getObject<T>(key: string, defaultValue: T | null = null): Promise<T | null> {
    const jsonString = await this.getString(key, '');
    if (!jsonString) {
      return defaultValue;
    }
    try {
      return JSON.parse(jsonString) as T;
    } catch {
      return defaultValue;
    }
  }

  /**
   * 删除指定键值
   */
  async remove(key: string): Promise<void> {
    if (!this.preferences) {
      throw new Error('StorageUtil not initialized');
    }
    await this.preferences.delete(key);
    await this.preferences.flush();
  }

  /**
   * 清空所有数据
   */
  async clear(): Promise<void> {
    if (!this.preferences) {
      throw new Error('StorageUtil not initialized');
    }
    await this.preferences.clear();
    await this.preferences.flush();
  }
}
