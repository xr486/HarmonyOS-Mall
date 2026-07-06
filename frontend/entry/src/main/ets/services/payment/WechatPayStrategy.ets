import { PayResponseParams, PaymentResult, PaymentResultStatus, PaymentMethodType } from '../../common/models/PaymentTypes';
import { BasePaymentStrategy } from './IPaymentStrategy';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'WechatPayStrategy';

interface WechatMockResult {
  errCode: number;
  errStr: string;
  returnKey: string;
  prepayId: string;
}

export class WechatPayStrategy extends BasePaymentStrategy {
  readonly method: string = PaymentMethodType.WECHAT_PAY;

  async pay(payParams: PayResponseParams): Promise<PaymentResult> {
    Logger.info(TAG, 'Starting WeChat payment');

    try {
      const params: Record<string, string> = payParams.payParams;
      const appidVal: string = params['appid'] !== undefined ? params['appid'] : '';
      const partneridVal: string = params['partnerid'] !== undefined ? params['partnerid'] : '';
      const prepayidVal: string = params['prepayid'] !== undefined ? params['prepayid'] : '';
      if (appidVal.length > 0) {
        Logger.info(TAG, '[MOCK MODE] Would call WeChat Pay SDK with params:');
        Logger.debug(TAG, 'appid=%{public}s, partnerid=%{public}s, prepayid=%{public}s',
          appidVal, partneridVal, prepayidVal);
      }

      await this.simulateSdkDelay(2000);

      const success: boolean = Math.random() > 0.1;

      if (success) {
        Logger.info(TAG, '[MOCK] WeChat payment completed');
        const mockResult: WechatMockResult = {
          errCode: 0,
          errStr: '',
          returnKey: '',
          prepayId: prepayidVal
        };
        Logger.debug(TAG, 'mock errCode: %{public}d', mockResult.errCode);
        return this.buildSuccessResult(payParams, 'MOCK_WECHAT_' + Date.now());
      } else {
        Logger.warn(TAG, '[MOCK] WeChat payment cancelled');
        return this.buildResult(payParams, PaymentResultStatus.FAILED, '-2', '用户取消支付');
      }

    } catch (e) {
      Logger.error(TAG, 'WeChat pay error');
      let errMsg: string = '微信支付调起失败';
      if (e instanceof Error) {
        errMsg = e.message;
      }
      return this.buildResult(payParams, PaymentResultStatus.FAILED, 'SDK_ERROR', errMsg);
    }
  }
}
