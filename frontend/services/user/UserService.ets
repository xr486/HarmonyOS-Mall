
import { DatabaseHelper } from '../../database/helper';
import { CloudDBUser } from '../../database/schema/CloudDBTypes';
import { User } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'UserService';

/**
 * 用户服务类
 */
export class UserService {
  private static instance: UserService | null = null;
  private dbHelper: DatabaseHelper;

  private constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  /**
   * 获取单例实例
   */
  static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService();
    }
    return UserService.instance;
  }

  /**
   * 将 CloudDBUser 转换为 User
   */
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

  /**
   * 将 User 转换为 CloudDBUser
   */
  private convertToCloudUser(user: User): CloudDBUser {
    const cloudUser = new CloudDBUser();
    cloudUser.userId = user.userId;
    cloudUser.phone = user.phone;
    cloudUser.nickname = user.nickname;
    cloudUser.avatar = user.avatar;
    cloudUser.huaweiAccount = user.huaweiAccount;
    cloudUser.createdAt = user.createdAt;
    cloudUser.updatedAt = user.updatedAt;
    return cloudUser;
  }

  /**
   * 根据用户 ID 获取用户信息
   */
  async getUserById(userId: string): Promise<User | null> {
    try {
      const cloudUser = await this.dbHelper.queryById(CloudDBUser, 'userId', userId);
      return cloudUser ? this.convertToUser(cloudUser) : null;
    } catch (error) {
      Logger.error(TAG, 'Failed to get user by id: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 根据手机号获取用户信息
   */
  async getUserByPhone(phone: string): Promise<User | null> {
    try {
      const allUsers = await this.dbHelper.queryAll(CloudDBUser);
      const foundUser = allUsers.find(u => u.phone === phone);
      return foundUser ? this.convertToUser(foundUser) : null;
    } catch (error) {
      Logger.error(TAG, 'Failed to get user by phone: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 创建用户
   */
  async createUser(user: User): Promise<void> {
    try {
      const cloudUser = this.convertToCloudUser(user);
      await this.dbHelper.insert(cloudUser);
      Logger.info(TAG, 'User created successfully: %{public}s', user.userId);
    } catch (error) {
      Logger.error(TAG, 'Failed to create user: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 更新用户信息
   */
  async updateUser(user: User): Promise<void> {
    try {
      const cloudUser = this.convertToCloudUser(user);
      await this.dbHelper.update(cloudUser);
      Logger.info(TAG, 'User updated successfully: %{public}s', user.userId);
    } catch (error) {
      Logger.error(TAG, 'Failed to update user: %{public}s', JSON.stringify(error));
      throw error;
    }
  }
}
