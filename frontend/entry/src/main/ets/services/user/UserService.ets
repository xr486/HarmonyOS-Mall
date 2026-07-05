import { HttpUtil, ApiResponse } from '../../common/utils/http/HttpUtil';
import { User } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'UserService';

interface UserResponse {
  userId: string;
  phone: string;
  nickname: string;
  avatar: string;
  huaweiAccount?: string;
  createdAt: number;
  updatedAt: number;
}

interface UpdateUserRequest {
  nickname: string;
  avatar: string;
}

function convertToUser(item: UserResponse): User {
  return {
    userId: item.userId,
    phone: item.phone,
    nickname: item.nickname,
    avatar: item.avatar,
    huaweiAccount: item.huaweiAccount,
    createdAt: item.createdAt,
    updatedAt: item.updatedAt
  };
}

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
      const response: ApiResponse<UserResponse> = await HttpUtil.get<UserResponse>(`/user/${userId}`);
      if (response.code === 200 && response.data) {
        return convertToUser(response.data);
      }
      return null;
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Failed to get user by id: %{public}s', errMsg);
      return null;
    }
  }

  async getUserByPhone(phone: string): Promise<User | null> {
    try {
      const response: ApiResponse<UserResponse> = await HttpUtil.get<UserResponse>(`/user/phone/${phone}`);
      if (response.code === 200 && response.data) {
        return convertToUser(response.data);
      }
      return null;
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Failed to get user by phone: %{public}s', errMsg);
      return null;
    }
  }

  async createUser(user: User): Promise<void> {
    try {
      await HttpUtil.post<object>('/user', user);
      Logger.info(TAG, 'User created successfully: %{public}s', user.userId);
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Failed to create user: %{public}s', errMsg);
      throw new Error('Failed to create user: ' + errMsg);
    }
  }

  async updateUser(user: User): Promise<void> {
    try {
      const req: UpdateUserRequest = {
        nickname: user.nickname,
        avatar: user.avatar
      };
      await HttpUtil.put<object>('/user/info', req);
      Logger.info(TAG, 'User updated successfully: %{public}s', user.userId);
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Failed to update user: %{public}s', errMsg);
      throw new Error('Failed to update user: ' + errMsg);
    }
  }
}
