import { DatabaseHelper } from '../helper/DatabaseHelper';
import {
  CloudDBBrowsingRecord,
  CloudDBOfflineCartItem,
  CloudDBDevicePreference
} from '../schema/CloudDBTypes';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'CacheManager';

/**
 * 端侧缓存管理器
 * 用于读写 CloudDB 中的 3 张缓存表（非业务数据）
 * - 浏览记录 → 跨设备同步、推荐算法
 * - 离线购物车 → 断网时暂存
 * - 设备偏好 → 主题/语言等跨设备同步
 */
export class CacheManager {
  private static instance: CacheManager | null = null;

  private constructor() {
  }

  static getInstance(): CacheManager {
    if (!CacheManager.instance) {
      CacheManager.instance = new CacheManager();
    }
    return CacheManager.instance;
  }

  // ==================== 浏览记录 ====================

  /**
   * 记录用户浏览了某商品
   */
  async addBrowsingRecord(userId: string, productId: string,
                          productName: string, productImage: string): Promise<void> {
    try {
      const db = DatabaseHelper.getInstance().getDatabase();
      if (!db) return;
      const record = new CloudDBBrowsingRecord();
      record.recordId = `br_${Date.now()}_${Math.random().toString(36).substr(2, 6)}`;
      record.userId = userId;
      record.productId = productId;
      record.productName = productName;
      record.productImage = productImage;
      record.timestamp = Date.now();
      await db.collection(CloudDBBrowsingRecord).upsert(record);
    } catch (e) {
      Logger.error(TAG, 'addBrowsingRecord error: %{public}s', JSON.stringify(e));
    }
  }

  /**
   * 获取用户最近 N 条浏览记录
   */
  async getRecentBrowsing(userId: string, limit: number = 20): Promise<CloudDBBrowsingRecord[]> {
    try {
      const db = DatabaseHelper.getInstance().getDatabase();
      if (!db) return [];
      const result = await db.collection(CloudDBBrowsingRecord)
        .query()
        .equalTo('userId', userId)
        .orderByDesc('timestamp')
        .limit(limit)
        .get();
      return result as CloudDBBrowsingRecord[];
    } catch (e) {
      Logger.error(TAG, 'getRecentBrowsing error: %{public}s', JSON.stringify(e));
      return [];
    }
  }

  // ==================== 离线购物车 ====================

  /**
   * 添加离线购物车项（断网时调用）
   */
  async addOfflineCartItem(item: CloudDBOfflineCartItem): Promise<void> {
    try {
      const db = DatabaseHelper.getInstance().getDatabase();
      if (!db) return;
      item.cartId = `oc_${Date.now()}_${Math.random().toString(36).substr(2, 6)}`;
      item.addedAt = Date.now();
      await db.collection(CloudDBOfflineCartItem).upsert(item);
    } catch (e) {
      Logger.error(TAG, 'addOfflineCartItem error: %{public}s', JSON.stringify(e));
    }
  }

  /**
   * 获取用户离线购物车
   */
  async getOfflineCart(userId: string): Promise<CloudDBOfflineCartItem[]> {
    try {
      const db = DatabaseHelper.getInstance().getDatabase();
      if (!db) return [];
      const result = await db.collection(CloudDBOfflineCartItem)
        .query()
        .equalTo('userId', userId)
        .get();
      return result as CloudDBOfflineCartItem[];
    } catch (e) {
      Logger.error(TAG, 'getOfflineCart error: %{public}s', JSON.stringify(e));
      return [];
    }
  }

  /**
   * 清空用户离线购物车（联机后同步到服务器时调用）
   */
  async clearOfflineCart(userId: string): Promise<void> {
    try {
      const items = await this.getOfflineCart(userId);
      const db = DatabaseHelper.getInstance().getDatabase();
      if (!db || items.length === 0) return;
      for (const item of items) {
        await db.collection(CloudDBOfflineCartItem).delete(item);
      }
    } catch (e) {
      Logger.error(TAG, 'clearOfflineCart error: %{public}s', JSON.stringify(e));
    }
  }

  // ==================== 设备偏好 ====================

  /**
   * 保存设备偏好（主题、语言等）
   */
  async setPreference(userId: string, key: string, value: string): Promise<void> {
    try {
      const db = DatabaseHelper.getInstance().getDatabase();
      if (!db) return;
      const existing = await db.collection(CloudDBDevicePreference)
        .query()
        .equalTo('userId', userId)
        .equalTo('prefKey', key)
        .limit(1)
        .get();

      if (existing.length > 0) {
        const pref = existing[0] as CloudDBDevicePreference;
        pref.prefValue = value;
        pref.updatedAt = Date.now();
        await db.collection(CloudDBDevicePreference).upsert(pref);
      } else {
        const pref = new CloudDBDevicePreference();
        pref.prefId = `dp_${userId}_${key}`;
        pref.userId = userId;
        pref.prefKey = key;
        pref.prefValue = value;
        pref.updatedAt = Date.now();
        await db.collection(CloudDBDevicePreference).upsert(pref);
      }
    } catch (e) {
      Logger.error(TAG, 'setPreference error: %{public}s', JSON.stringify(e));
    }
  }

  /**
   * 获取设备偏好
   */
  async getPreference(userId: string, key: string, defaultValue: string = ''): Promise<string> {
    try {
      const db = DatabaseHelper.getInstance().getDatabase();
      if (!db) return defaultValue;
      const result = await db.collection(CloudDBDevicePreference)
        .query()
        .equalTo('userId', userId)
        .equalTo('prefKey', key)
        .limit(1)
        .get();
      if (result.length > 0) {
        return (result[0] as CloudDBDevicePreference).prefValue;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
}
