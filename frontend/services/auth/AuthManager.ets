import { AGCAuth, VerifyCodeSettingBuilder, PhoneUserBuilder } from '@hw-agconnect/hmcore';
import { Logger } from '../../common/utils/logger/Logger';
import { StorageUtil } from '../../common/utils/storage/StorageUtil';
import { StorageKeys } from '../../common/constants/StorageKeys';

const TAG = 'AuthManager';

export class AuthManager {
  private static instance: AuthManager | null = null;
  private auth: AGCAuth | null = null;

  private constructor() {}

  static getInstance(): AuthManager {
    if (!AuthManager.instance) {
      AuthManager.instance = new AuthManager();
    }
    return AuthManager.instance;
  }

  init(): void {
    try {
      this.auth = AGCAuth.getInstance();
      Logger.info(TAG, 'AuthManager initialized');
    } catch (error) {
      Logger.error(TAG, 'Failed to initialize AuthManager: %{public}s', JSON.stringify(error));
    }
  }

  async getCurrentUser() {
    if (!this.auth) {
      return null;
    }
    return await this.auth.currentUser();
  }

  async sendVerifyCode(phoneNumber: string, countryCode: string = '86') {
    if (!this.auth) {
      throw new Error('AuthManager not initialized');
    }

    try {
      const setting = new VerifyCodeSettingBuilder()
        .setAction(0)
        .setSendInterval(60)
        .build();

      const result = await this.auth.requestVerifyCode(countryCode, phoneNumber, setting);
      Logger.info(TAG, 'Verify code sent successfully');
      return result;
    } catch (error) {
      Logger.error(TAG, 'Failed to send verify code: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  async signInWithPhone(
    phoneNumber: string,
    verifyCode: string,
    countryCode: string = '86'
  ) {
    if (!this.auth) {
      throw new Error('AuthManager not initialized');
    }

    try {
      const phoneUser = new PhoneUserBuilder()
        .setCountryCode(countryCode)
        .setPhoneNumber(phoneNumber)
        .setVerifyCode(verifyCode)
        .build();

      const result = await this.auth.signIn(phoneUser);

      await StorageUtil.getInstance().setBoolean(StorageKeys.IS_LOGGED_IN, true);

      Logger.info(TAG, 'Signed in with phone successfully');
      return result;
    } catch (error) {
      Logger.error(TAG, 'Failed to sign in with phone: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  async signInWithHuawei() {
    if (!this.auth) {
      throw new Error('AuthManager not initialized');
    }

    try {
      const result = await this.auth.signIn();
      await StorageUtil.getInstance().setBoolean(StorageKeys.IS_LOGGED_IN, true);
      Logger.info(TAG, 'Signed in with Huawei account successfully');
      return result;
    } catch (error) {
      Logger.error(TAG, 'Failed to sign in with Huawei: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  async signOut(): Promise<void> {
    if (!this.auth) {
      return;
    }

    try {
      await this.auth.signOut();
      await StorageUtil.getInstance().remove(StorageKeys.USER_TOKEN);
      await StorageUtil.getInstance().remove(StorageKeys.USER_INFO);
      await StorageUtil.getInstance().setBoolean(StorageKeys.IS_LOGGED_IN, false);
      Logger.info(TAG, 'Signed out successfully');
    } catch (error) {
      Logger.error(TAG, 'Failed to sign out: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  async isLoggedIn(): Promise<boolean> {
    return await StorageUtil.getInstance().getBoolean(StorageKeys.IS_LOGGED_IN, false);
  }
}
