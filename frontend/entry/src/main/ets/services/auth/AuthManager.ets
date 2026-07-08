import { HttpUtil, ApiResponse, LoginBody, PasswordLoginBody, SendCodeBody, RegisterBody, LoginResult } from '../../common/utils/http/HttpUtil';
import { Logger } from '../../common/utils/logger/Logger';
import { StorageUtil } from '../../common/utils/storage/StorageUtil';
import { TokenFileUtil } from '../../common/utils/storage/TokenFileUtil';
import { StorageKeys } from '../../common/constants/StorageKeys';
import common from '@ohos.app.ability.common';

const TAG = 'AuthManager';

class LoginData {
  token: string = '';
  userId: string = '';
  phone: string = '';
  nickname: string = '';
}

function toLoginData(data: LoginResult): LoginData {
  const result: LoginData = new LoginData();
  result.token = data.token;
  result.userId = data.userId;
  result.phone = data.phone;
  result.nickname = data.nickname;
  return result;
}

export class AuthManager {
  private static instance: AuthManager | null = null;

  private constructor() {
  }

  static getInstance(): AuthManager {
    if (!AuthManager.instance) {
      AuthManager.instance = new AuthManager();
    }
    return AuthManager.instance;
  }

  init(): void {
    Logger.info(TAG, 'HttpAuthManager init — using Java backend');
  }

  async requestVerifyCode(phoneNumber: string): Promise<Object | null> {
    try {
      const body: SendCodeBody = new SendCodeBody();
      body.phone = phoneNumber;
      const res: ApiResponse<Object> = await HttpUtil.post('/auth/send-code', body);
      if (res.code === 200) {
        return res.data;
      }
      Logger.error(TAG, 'sendVerifyCode failed: %{public}s', res.message);
      return null;
    } catch (e) {
      Logger.error(TAG, 'sendVerifyCode error: %{public}s', JSON.stringify(e));
      return null;
    }
  }

  async register(phoneNumber: string, password: string, verifyCode: string): Promise<LoginData | null> {
    try {
      const body: RegisterBody = new RegisterBody();
      body.phone = phoneNumber;
      body.password = password;
      body.code = verifyCode;
      const res: ApiResponse<LoginResult> = await HttpUtil.post<LoginResult>('/auth/register', body);

      if (res.code === 200 && res.data) {
        await this.saveLoginState(res.data);
        Logger.info(TAG, 'register success');
        return toLoginData(res.data);
      }
      Logger.error(TAG, 'register failed: %{public}s', res.message);
      return null;
    } catch (e) {
      Logger.error(TAG, 'register error: %{public}s', JSON.stringify(e));
      return null;
    }
  }

  async signInByPassword(phoneNumber: string, password: string): Promise<LoginData | null> {
    try {
      const body: PasswordLoginBody = new PasswordLoginBody();
      body.phone = phoneNumber;
      body.password = password;
      const res: ApiResponse<LoginResult> = await HttpUtil.post<LoginResult>('/auth/login/password', body);

      if (res.code === 200 && res.data) {
        await this.saveLoginState(res.data);
        Logger.info(TAG, 'signInByPassword success');
        return toLoginData(res.data);
      }
      Logger.error(TAG, 'signInByPassword failed: %{public}s', res.message);
      return null;
    } catch (e) {
      Logger.error(TAG, 'signInByPassword error: %{public}s', JSON.stringify(e));
      return null;
    }
  }

  async signInByCode(phoneNumber: string, verifyCode: string): Promise<LoginData | null> {
    try {
      const body: LoginBody = new LoginBody();
      body.phone = phoneNumber;
      body.code = verifyCode;
      const res: ApiResponse<LoginResult> = await HttpUtil.post<LoginResult>('/auth/login', body);

      if (res.code === 200 && res.data) {
        await this.saveLoginState(res.data);
        Logger.info(TAG, 'signInByCode success');
        return toLoginData(res.data);
      }
      Logger.error(TAG, 'signInByCode failed: %{public}s', res.message);
      return null;
    } catch (e) {
      Logger.error(TAG, 'signInByCode error: %{public}s', JSON.stringify(e));
      return null;
    }
  }

  async signOut(): Promise<void> {
    try {
      await HttpUtil.post<Object>('/auth/logout');
    } catch (e) {
      // ignore
    }
    const storage: StorageUtil = StorageUtil.getInstance();
    await storage.remove(StorageKeys.USER_TOKEN);
    await storage.remove(StorageKeys.USER_PHONE);
    await storage.setBoolean(StorageKeys.IS_LOGGED_IN, false);
    try {
      const ctx: common.Context | undefined = AppStorage.get<common.Context>('abilityContext') as common.Context | undefined;
      if (ctx) {
        TokenFileUtil.clearToken(ctx);
      }
    } catch (e) {
      // ignore
    }
    Logger.info(TAG, 'signOut success');
  }

  async isLoggedIn(): Promise<boolean> {
    return await StorageUtil.getInstance().getBoolean(StorageKeys.IS_LOGGED_IN, false);
  }

  async getCurrentUser(): Promise<Object | null> {
    try {
      const res: ApiResponse<Object> = await HttpUtil.get('/user/info');
      if (res.code === 200) {
        return res.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  private async saveLoginState(data: LoginResult): Promise<void> {
    const storage: StorageUtil = StorageUtil.getInstance();
    await storage.setString(StorageKeys.USER_TOKEN, data.token);
    await storage.setString(StorageKeys.USER_PHONE, data.phone);
    await storage.setBoolean(StorageKeys.IS_LOGGED_IN, true);
    // 同步到跨进程文件，供 ServiceCardFormAbility 读取
    try {
      const ctx: common.Context | undefined = AppStorage.get<common.Context>('abilityContext') as common.Context | undefined;
      if (ctx) {
        TokenFileUtil.saveToken(ctx, data.token);
      }
    } catch (e) {
      // ignore
    }
  }
}
