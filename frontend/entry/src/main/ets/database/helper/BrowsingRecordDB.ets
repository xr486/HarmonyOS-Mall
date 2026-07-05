import cloud from '@hw-agconnect/cloud';
import { DatabaseHelper } from './DatabaseHelper';
import { CloudDBBrowsingRecord } from '../schema/CloudDBTypes';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = '[BrowsingRecordDB]';

interface QueryCondition {
  userId: string;
  productName?: string;
  startTime?: number;
  endTime?: number;
}

interface PageResult {
  records: CloudDBBrowsingRecord[];
  total: number;
  pageNum: number;
  pageSize: number;
}

export class BrowsingRecordDB {
  private static instance: BrowsingRecordDB | null = null;
  private db: cloud.Database | null = null;

  private constructor() {
  }

  static getInstance(): BrowsingRecordDB {
    if (!BrowsingRecordDB.instance) {
      BrowsingRecordDB.instance = new BrowsingRecordDB();
    }
    return BrowsingRecordDB.instance;
  }

  private getDb(): cloud.Database | null {
    if (!this.db) {
      const helper: DatabaseHelper = DatabaseHelper.getInstance();
      helper.init();
      this.db = helper.getDatabase();
    }
    return this.db;
  }

  async upsert(record: CloudDBBrowsingRecord): Promise<boolean> {
    const database: cloud.Database | null = this.getDb();
    if (!database) {
      Logger.error(TAG, 'Database not initialized');
      return false;
    }

    try {
      if (!record.recordId) {
        record.recordId = this.generateId();
      }
      if (!record.timestamp) {
        record.timestamp = Date.now();
      }

      const result: number = await database.executeSql(
        `SELECT COUNT(*) FROM browsing_record WHERE recordId = ?`,
        [record.recordId]
      ) as number;

      if (result > 0) {
        await database.executeSql(
          `UPDATE browsing_record SET userId = ?, productId = ?, productName = ?, productImage = ?, timestamp = ? WHERE recordId = ?`,
          [record.userId, record.productId, record.productName, record.productImage, record.timestamp, record.recordId]
        );
        Logger.info(TAG, 'Updated browsing record: %{public}s', record.recordId);
      } else {
        await database.executeSql(
          `INSERT INTO browsing_record (recordId, userId, productId, productName, productImage, timestamp) VALUES (?, ?, ?, ?, ?, ?)`,
          [record.recordId, record.userId, record.productId, record.productName, record.productImage, record.timestamp]
        );
        Logger.info(TAG, 'Inserted browsing record: %{public}s', record.recordId);
      }
      return true;
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Upsert failed: %{public}s', errMsg);
      return false;
    }
  }

  async queryByUserId(userId: string): Promise<CloudDBBrowsingRecord[]> {
    const database: cloud.Database | null = this.getDb();
    if (!database) {
      Logger.error(TAG, 'Database not initialized');
      return [];
    }

    try {
      const result: Object[] = await database.query(
        CloudDBBrowsingRecord.className,
        database.where('userId').equalTo(userId)
          .orderByDesc('timestamp')
      ) as Object[];

      return this.convertResults(result);
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Query by userId failed: %{public}s', errMsg);
      return [];
    }
  }

  async queryByUserIdWithPage(userId: string, pageNum: number, pageSize: number): Promise<PageResult> {
    const database: cloud.Database | null = this.getDb();
    if (!database) {
      Logger.error(TAG, 'Database not initialized');
      return { records: [], total: 0, pageNum, pageSize };
    }

    try {
      const startIndex: number = (pageNum - 1) * pageSize;

      const totalResult: Object[] = await database.query(
        CloudDBBrowsingRecord.className,
        database.where('userId').equalTo(userId)
      ) as Object[];
      const total: number = totalResult.length;

      const pageResult: Object[] = await database.query(
        CloudDBBrowsingRecord.className,
        database.where('userId').equalTo(userId)
          .orderByDesc('timestamp')
          .limit(pageSize)
          .offset(startIndex)
      ) as Object[];

      return {
        records: this.convertResults(pageResult),
        total,
        pageNum,
        pageSize
      };
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Query with page failed: %{public}s', errMsg);
      return { records: [], total: 0, pageNum, pageSize };
    }
  }

  async deleteByRecordId(recordId: string): Promise<boolean> {
    const database: cloud.Database | null = this.getDb();
    if (!database) {
      Logger.error(TAG, 'Database not initialized');
      return false;
    }

    try {
      await database.executeSql(
        `DELETE FROM browsing_record WHERE recordId = ?`,
        [recordId]
      );
      Logger.info(TAG, 'Deleted browsing record: %{public}s', recordId);
      return true;
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Delete by recordId failed: %{public}s', errMsg);
      return false;
    }
  }

  async clearByUserId(userId: string): Promise<boolean> {
    const database: cloud.Database | null = this.getDb();
    if (!database) {
      Logger.error(TAG, 'Database not initialized');
      return false;
    }

    try {
      await database.executeSql(
        `DELETE FROM browsing_record WHERE userId = ?`,
        [userId]
      );
      Logger.info(TAG, 'Cleared all browsing records for user: %{public}s', userId);
      return true;
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Clear by userId failed: %{public}s', errMsg);
      return false;
    }
  }

  async queryWithConditions(conditions: QueryCondition, pageNum: number, pageSize: number): Promise<PageResult> {
    const database: cloud.Database | null = this.getDb();
    if (!database) {
      Logger.error(TAG, 'Database not initialized');
      return { records: [], total: 0, pageNum, pageSize };
    }

    try {
      let query = database.where('userId').equalTo(conditions.userId);

      if (conditions.productName && conditions.productName.trim()) {
        query = query.contains('productName', conditions.productName);
      }

      if (conditions.startTime !== undefined) {
        query = query.greaterThanOrEqualTo('timestamp', conditions.startTime);
      }

      if (conditions.endTime !== undefined) {
        query = query.lessThanOrEqualTo('timestamp', conditions.endTime);
      }

      const totalResult: Object[] = await database.query(
        CloudDBBrowsingRecord.className,
        query
      ) as Object[];
      const total: number = totalResult.length;

      const startIndex: number = (pageNum - 1) * pageSize;
      const pageResult: Object[] = await database.query(
        CloudDBBrowsingRecord.className,
        query.orderByDesc('timestamp')
          .limit(pageSize)
          .offset(startIndex)
      ) as Object[];

      return {
        records: this.convertResults(pageResult),
        total,
        pageNum,
        pageSize
      };
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Query with conditions failed: %{public}s', errMsg);
      return { records: [], total: 0, pageNum, pageSize };
    }
  }

  private convertResults(results: Object[]): CloudDBBrowsingRecord[] {
    const records: CloudDBBrowsingRecord[] = [];
    for (let i: number = 0; i < results.length; i++) {
      const item: Object = results[i];
      const record: CloudDBBrowsingRecord = new CloudDBBrowsingRecord();
      const itemObj: Record<string, any> = item as Record<string, any>;
      record.recordId = itemObj.recordId || '';
      record.userId = itemObj.userId || '';
      record.productId = itemObj.productId || '';
      record.productName = itemObj.productName || '';
      record.productImage = itemObj.productImage || '';
      record.timestamp = itemObj.timestamp || 0;
      records.push(record);
    }
    return records;
  }

  private generateId(): string {
    const timestamp: number = Date.now();
    const random: number = Math.floor(Math.random() * 1000000);
    return `BR_${timestamp}_${random}`;
  }
}