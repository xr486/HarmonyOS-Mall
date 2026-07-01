import cloud from '@hw-agconnect/cloud';
import { Database } from '@hw-agconnect/cloud';
import { Logger } from '../../common/utils/logger/Logger';
import { CLOUD_DB_OBJECT_TYPES } from '../schema/CloudDBTypes';

const TAG = '[DatabaseHelper]';

interface PermissionRole {
  role: string;
  rights: string[];
}

interface ObjectPermission {
  permissions: PermissionRole[];
}

export class DatabaseHelper {
  private static instance: DatabaseHelper | null = null;
  private db: Database | null = null;
  private isInited: boolean = false;

  private constructor() {
  }

  static getInstance(): DatabaseHelper {
    if (!DatabaseHelper.instance) {
      DatabaseHelper.instance = new DatabaseHelper();
    }
    return DatabaseHelper.instance;
  }

  init(): void {
    if (this.isInited) {
      return;
    }
    try {
      const objCount: number = CLOUD_DB_OBJECT_TYPES.length;
      const permissions: ObjectPermission[] = [];
      for (let i: number = 0; i < objCount; i++) {
        const roleList: PermissionRole[] = [
          { role: 'USER', rights: ['read', 'create', 'update', 'delete'] }
        ];
        permissions.push({ permissions: roleList });
      }

      this.db = cloud.database({
        zoneName: 'MainZone',
        objectTypeInfo: {
          schemaVersion: 1,
          permissions: permissions,
          objectTypes: CLOUD_DB_OBJECT_TYPES
        },
        syncMode: 0
      });
      this.isInited = true;
      Logger.info(TAG, 'init success');
    } catch (e) {
      const errMsg: string = JSON.stringify(e);
      Logger.error(TAG, 'init failed: %{public}s', errMsg);
    }
  }

  isReady(): boolean {
    return this.isInited && this.db !== null;
  }

  getDatabase(): Database | null {
    return this.db;
  }
}
