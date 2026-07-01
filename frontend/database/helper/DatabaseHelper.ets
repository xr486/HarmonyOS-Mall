import { AGConnectCloudDB, CloudDBZone, CloudDBZoneConfig } from '@hw-agconnect/cloud';
import { CloudDBObject } from '../schema/CloudDBTypes';
import hilog from '@ohos.hilog';

const TAG = '[DatabaseHelper]';
const DOMAIN = 0x0000;

export class DatabaseHelper {
  private static instance: DatabaseHelper | null = null;
  private cloudDB: AGConnectCloudDB | null = null;
  private cloudDBZone: CloudDBZone | null = null;
  private isInitialized: boolean = false;

  private constructor() {}

  public static getInstance(): DatabaseHelper {
    if (!DatabaseHelper.instance) {
      DatabaseHelper.instance = new DatabaseHelper();
    }
    return DatabaseHelper.instance;
  }

  public async init(): Promise<void> {
    if (this.isInitialized) {
      hilog.info(DOMAIN, TAG, 'DatabaseHelper already initialized');
      return;
    }

    try {
      this.cloudDB = AGConnectCloudDB.getInstance();

      const config = new CloudDBZoneConfig(
        'MainZone',
        CloudDBZoneConfig.CloudDBZoneSyncProperty.CLOUDDBZONE_CLOUD_CACHE,
        CloudDBZoneConfig.CloudDBZoneAccessProperty.CLOUDDBZONE_PUBLIC
      );

      this.cloudDBZone = await this.cloudDB.openCloudDBZone(config, true);

      this.isInitialized = true;
      hilog.info(DOMAIN, TAG, 'DatabaseHelper initialized successfully');
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to initialize DatabaseHelper: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  public async insert<T extends CloudDBObject>(object: T): Promise<void> {
    if (!this.cloudDBZone) {
      throw new Error('DatabaseHelper not initialized');
    }

    try {
      await this.cloudDBZone.executeUpsert(object);
      hilog.info(DOMAIN, TAG, 'Inserted %{public}s successfully', object.getClassName());
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to insert: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  public async insertBatch<T extends CloudDBObject>(objects: T[]): Promise<void> {
    if (!this.cloudDBZone) {
      throw new Error('DatabaseHelper not initialized');
    }

    try {
      await this.cloudDBZone.executeUpsert(objects);
      hilog.info(DOMAIN, TAG, 'Inserted batch %{public}d items successfully', objects.length);
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to insert batch: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  public async update<T extends CloudDBObject>(object: T): Promise<void> {
    if (!this.cloudDBZone) {
      throw new Error('DatabaseHelper not initialized');
    }

    try {
      await this.cloudDBZone.executeUpsert(object);
      hilog.info(DOMAIN, TAG, 'Updated %{public}s successfully', object.getClassName());
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to update: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  public async delete<T extends CloudDBObject>(object: T): Promise<void> {
    if (!this.cloudDBZone) {
      throw new Error('DatabaseHelper not initialized');
    }

    try {
      await this.cloudDBZone.executeDelete(object);
      hilog.info(DOMAIN, TAG, 'Deleted %{public}s successfully', object.getClassName());
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to delete: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  public async queryAll<T extends CloudDBObject>(clazz: new () => T): Promise<T[]> {
    if (!this.cloudDBZone) {
      throw new Error('DatabaseHelper not initialized');
    }

    try {
      const snapshot = await this.cloudDBZone.executeQuery(clazz);
      const result = snapshot.getSnapshotObjects();
      hilog.info(DOMAIN, TAG, 'Queried %{public}d %{public}s items', result.length, clazz.name);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to query all: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  public async queryById<T extends CloudDBObject>(
    clazz: new () => T,
    idField: string,
    id: string
  ): Promise<T | null> {
    if (!this.cloudDBZone) {
      throw new Error('DatabaseHelper not initialized');
    }

    try {
      const snapshot = await this.cloudDBZone.executeQuery(
        clazz,
        (query) => query.where().equalTo(idField, id)
      );
      const result = snapshot.getSnapshotObjects();
      return result.length > 0 ? result[0] : null;
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to query by id: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  public async close(): Promise<void> {
    if (this.cloudDBZone) {
      try {
        await this.cloudDB!.closeCloudDBZone(this.cloudDBZone);
        this.cloudDBZone = null;
        this.isInitialized = false;
        hilog.info(DOMAIN, TAG, 'DatabaseHelper closed');
      } catch (error) {
        hilog.error(DOMAIN, TAG, 'Failed to close DatabaseHelper: %{public}s', JSON.stringify(error));
      }
    }
  }
}
