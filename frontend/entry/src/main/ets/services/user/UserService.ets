import { DatabaseHelper } from '../../database/helper/DatabaseHelper';
import { CloudDBUser } from '../../database/schema/CloudDBTypes';
import { User } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'UserService';

export class UserService {
  private static instance: UserService | null = null;
  private dbHelper: DatabaseHelper;

  private constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService();
    }
    return UserService.instance;
  }

  private convertToUser(cloudUser: CloudDBUser): User {
    return {
      userId: cloudUser.userId || '',
      phone: cloudUser.phone || '',
      nickname: cloudUser.nickname || '',
      avatar: cloudUser.avatar || '',
      huaweiAccount: cloudUser.huaweiAccount,
      createdAt: cloudUser.createdAt || Date.now(),
      updatedAt: cloudUser.updatedAt || Date.now()
    };
  }

  private convertToCloudUser(user: User): CloudDBUser {
    const cloudUser: CloudDBUser = new CloudDBUser();
    cloudUser.userId = user.userId;
    cloudUser.phone = user.phone;
    cloudUser.nickname = user.nickname;
    cloudUser.avatar = user.avatar;
    cloudUser.huaweiAccount = user.huaweiAccount || '';
    cloudUser.createdAt = user.createdAt;
    cloudUser.updatedAt = user.updatedAt;
    return cloudUser;
  }

  async getUserById(userId: string): Promise<User | null> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return null;
      }
      const collection = db.collection(CloudDBUser);
      const cloudUsers: CloudDBUser[] = await collection.query().equalTo('userId', userId).get();
      if (cloudUsers.length > 0) {
        return this.convertToUser(cloudUsers[0]);
      }
      return null;
    } catch (error) {
      Logger.error(TAG, 'Failed to get user by id: %{public}s', JSON.stringify(error));
      throw new Error('Failed to get user by id: ' + JSON.stringify(error));
    }
  }

  async getUserByPhone(phone: string): Promise<User | null> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return null;
      }
      const collection = db.collection(CloudDBUser);
      const cloudUsers: CloudDBUser[] = await collection.query().get();
      const foundUser: CloudDBUser | undefined = cloudUsers.find((u: CloudDBUser) => u.phone === phone);
      return foundUser ? this.convertToUser(foundUser) : null;
    } catch (error) {
      Logger.error(TAG, 'Failed to get user by phone: %{public}s', JSON.stringify(error));
      throw new Error('Failed to get user by phone: ' + JSON.stringify(error));
    }
  }

  async createUser(user: User): Promise<void> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return;
      }
      const cloudUser: CloudDBUser = this.convertToCloudUser(user);
      const collection = db.collection(CloudDBUser);
      await collection.upsert(cloudUser);
      Logger.info(TAG, 'User created successfully: %{public}s', user.userId);
    } catch (error) {
      Logger.error(TAG, 'Failed to create user: %{public}s', JSON.stringify(error));
      throw new Error('Failed to create user: ' + JSON.stringify(error));
    }
  }

  async updateUser(user: User): Promise<void> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return;
      }
      const cloudUser: CloudDBUser = this.convertToCloudUser(user);
      const collection = db.collection(CloudDBUser);
      await collection.upsert(cloudUser);
      Logger.info(TAG, 'User updated successfully: %{public}s', user.userId);
    } catch (error) {
      Logger.error(TAG, 'Failed to update user: %{public}s', JSON.stringify(error));
      throw new Error('Failed to update user: ' + JSON.stringify(error));
    }
  }
}
