import { PayResponseParams, PaymentResult, PaymentResultStatus, PaymentMethodType } from '../../common/models/PaymentTypes';
import { BasePaymentStrategy } from './IPaymentStrategy';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'HuaweiPayStrategy';

export class HuaweiPayStrategy extends BasePaymentStrategy {
  readonly method: string = PaymentMethodType.HUAWEI_PAY;

  async pay(payParams: PayResponseParams): Promise<PaymentResult> {
    Logger.info(TAG, 'Starting Huawei Pay payment');

    try {
      const params: Record<string, string> = payParams.payParams;
      const appidVal: string = params['appid'] !== undefined ? params['appid'] : '';
      const cpIdVal: string = params['cpId'] !== undefined ? params['cpId'] : '';
      const merchantIdVal: string = params['merchantId'] !== undefined ? params['merchantId'] : '';
      if (appidVal.length > 0) {
        Logger.info(TAG, '[MOCK MODE] Would call Huawei Pay SDK with params:');
        Logger.debug(TAG, 'appid=%{public}s, cpId=%{public}s, merchantId=%{public}s',
          appidVal, cpIdVal, merchantIdVal);
      }

      await this.simulateSdkDelay(1800);

      const isHmsAvailable: boolean = Math.random() > 0.05;
      if (!isHmsAvailable) {
        Logger.warn(TAG, '[MOCK] HMS not available or Huawei Pay not supported');
        return this.buildResult(payParams, PaymentResultStatus.FAILED, '1002',
          '未安装华为移动服务或当前设备不支持华为支付');
      }

      const success: boolean = Math.random() > 0.1;

      if (success) {
        Logger.info(TAG, '[MOCK] Huawei payment completed');
        return this.buildSuccessResult(payParams, 'MOCK_HUAWEI_' + Date.now());
      } else {
        Logger.warn(TAG, '[MOCK] Huawei payment cancelled');
        return this.buildResult(payParams, PaymentResultStatus.FAILED, '1001', '用户取消支付');
      }

    } catch (e) {
      Logger.error(TAG, 'Huawei pay error');
      let errMsg: string = '华为支付调起失败';
      if (e instanceof Error) {
        errMsg = e.message;
      }
      return this.buildResult(payParams, PaymentResultStatus.FAILED, 'SDK_ERROR', errMsg);
    }
  }
}
