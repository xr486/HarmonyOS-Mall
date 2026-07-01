import cloud, { Auth, VerifyCodeParam, VerifyCodeAction, SignInParam, PhoneCredentialInfo } from '@hw-agconnect/cloud';
import { Logger } from '../../common/utils/logger/Logger';
import { StorageUtil } from '../../common/utils/storage/StorageUtil';
import { StorageKeys } from '../../common/constants/StorageKeys';

const TAG = 'AuthManager';

export class AuthManager {
  private static instance: AuthManager | null = null;
  private authInstance: Auth | null = null;

  private constructor() {
  }

  static getInstance(): AuthManager {
    if (!AuthManager.instance) {
      AuthManager.instance = new AuthManager();
    }
    return AuthManager.instance;
  }

  init(): void {
    try {
      this.authInstance = cloud.auth();
      Logger.info(TAG, 'init success');
    } catch (e) {
      Logger.error(TAG, 'init failed: %{public}s', (e as Error).message);
    }
  }

  async getCurrentUser(): Promise<Object | null> {
    if (!this.authInstance) {
      return null;
    }
    try {
      return await this.authInstance.getCurrentUser();
    } catch (e) {
      Logger.error(TAG, 'getCurrentUser failed: %{public}s', (e as Error).message);
      return null;
    }
  }

  async requestVerifyCode(
    countryCode: string,
    phoneNumber: string,
    action: VerifyCodeAction,
    lang: string,
    sendInterval?: number
  ): Promise<Object | null> {
    if (!this.authInstance) {
      return null;
    }
    try {
      const verifyCodeParam: VerifyCodeParam = {
        verifyCodeType: {
          kind: 'phone',
          phoneNumber: phoneNumber,
          countryCode: countryCode
        },
        action: action,
        lang: lang,
        sendInterval: sendInterval
      };
      return await this.authInstance.requestVerifyCode(verifyCodeParam);
    } catch (e) {
      Logger.error(TAG, 'requestVerifyCode failed: %{public}s', (e as Error).message);
      return null;
    }
  }

  async signIn(
    countryCode: string,
    phoneNumber: string,
    verifyCode: string
  ): Promise<Object | null> {
    if (!this.authInstance) {
      return null;
    }
    try {
      const credentialInfo: PhoneCredentialInfo = {
        kind: 'phone',
        countryCode: countryCode,
        phoneNumber: phoneNumber,
        verifyCode: verifyCode
      };
      const signInParam: SignInParam = {
        credentialInfo: credentialInfo,
        autoCreateUser: true
      };
      const result = await this.authInstance.signIn(signInParam);
      await StorageUtil.getInstance().setBoolean(StorageKeys.IS_LOGGED_IN, true);
      Logger.info(TAG, 'signIn success');
      return result;
    } catch (e) {
      Logger.error(TAG, 'signIn failed: %{public}s', (e as Error).message);
      return null;
    }
  }

  async signInAnonymously(): Promise<Object | null> {
    if (!this.authInstance) {
      return null;
    }
    try {
      const result = await this.authInstance.signInAnonymously();
      await StorageUtil.getInstance().setBoolean(StorageKeys.IS_LOGGED_IN, true);
      Logger.info(TAG, 'signInAnonymously success');
      return result;
    } catch (e) {
      Logger.error(TAG, 'signInAnonymously failed: %{public}s', (e as Error).message);
      return null;
    }
  }

  async signOut(): Promise<void> {
    if (!this.authInstance) {
      return;
    }
    try {
      await this.authInstance.signOut();
      await StorageUtil.getInstance().remove(StorageKeys.USER_TOKEN);
      await StorageUtil.getInstance().remove(StorageKeys.USER_INFO);
      await StorageUtil.getInstance().setBoolean(StorageKeys.IS_LOGGED_IN, false);
      Logger.info(TAG, 'signOut success');
    } catch (e) {
      Logger.error(TAG, 'signOut failed: %{public}s', (e as Error).message);
    }
  }

  async isLoggedIn(): Promise<boolean> {
    return await StorageUtil.getInstance().getBoolean(StorageKeys.IS_LOGGED_IN, false);
  }
}
