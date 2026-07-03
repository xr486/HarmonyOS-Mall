import { HttpUtil, ApiResponse, UpdateUserBody } from '../../common/utils/http/HttpUtil';
import { User } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'UserService';

export class UserService {
  private static instance: UserService | null = null;

  private constructor() {
  }

  static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService();
    }
    return UserService.instance;
  }

  async getUserById(userId: string): Promise<User | null> {
    try {
      const res: ApiResponse<User> = await HttpUtil.get('/user/info');
      if (res.code === 200) {
        return res.data;
      }
      Logger.error(TAG, 'getUserById failed: %{public}s', res.message);
      return null;
    } catch (e) {
      Logger.error(TAG, 'getUserById error: %{public}s', JSON.stringify(e));
      return null;
    }
  }

  async getUserByPhone(phone: string): Promise<User | null> {
    try {
      const res: ApiResponse<User> = await HttpUtil.get('/user/info');
      if (res.code === 200) {
        return res.data;
      }
      return null;
    } catch (e) {
      Logger.error(TAG, 'getUserByPhone error: %{public}s', JSON.stringify(e));
      return null;
    }
  }

  async updateUserInfo(data: Record<string, string>): Promise<User | null> {
    try {
      const res: ApiResponse<User> = await HttpUtil.put('/user/info', data);
      if (res.code === 200) {
        return res.data;
      }
      Logger.error(TAG, 'updateUserInfo failed: %{public}s', res.message);
      return null;
    } catch (e) {
      Logger.error(TAG, 'updateUserInfo error: %{public}s', JSON.stringify(e));
      return null;
    }
  }

  async updateUser(user: User): Promise<User | null> {
    try {
      const body: UpdateUserBody = new UpdateUserBody();
      body.nickname = user.nickname || '';
      const res: ApiResponse<User> = await HttpUtil.put('/user/info', body);
      if (res.code === 200) {
        return res.data;
      }
      return null;
    } catch (e) {
      Logger.error(TAG, 'updateUser error: %{public}s', JSON.stringify(e));
      return null;
    }
  }
}
