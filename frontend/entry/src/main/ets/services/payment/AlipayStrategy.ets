import { PayResponseParams, PaymentResult, PaymentResultStatus, PaymentMethodType } from '../../common/models/PaymentTypes';
import { BasePaymentStrategy } from './IPaymentStrategy';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'AlipayStrategy';

interface MockResultData {
  resultStatus: string;
  memo: string;
  result: string;
}

export class AlipayStrategy extends BasePaymentStrategy {
  readonly method: string = PaymentMethodType.ALIPAY;

  async pay(payParams: PayResponseParams): Promise<PaymentResult> {
    Logger.info(TAG, 'Starting Alipay payment, orderStr length: %{public}d',
      payParams.orderStr !== undefined ? payParams.orderStr.length : 0);

    try {
      if (payParams.orderStr !== undefined) {
        Logger.info(TAG, '[MOCK MODE] Would call Alipay SDK with orderStr');
        Logger.debug(TAG, 'orderStr prefix: %{public}s',
          payParams.orderStr.substring(0, Math.min(100, payParams.orderStr.length)));
      }

      await this.simulateSdkDelay(2000);

      const success: boolean = Math.random() > 0.1;

      if (success) {
        Logger.info(TAG, '[MOCK] Alipay payment completed');
        const mockResult: MockResultData = {
          resultStatus: '9000',
          memo: 'MOCK_ALIPAY_' + Date.now(),
          result: 'mock_result_data'
        };
        Logger.info(TAG, '[MOCK] Sync result status: %{public}s', mockResult.resultStatus);
        return this.buildSuccessResult(payParams, mockResult.memo);
      } else {
        Logger.warn(TAG, '[MOCK] Alipay payment cancelled by user');
        return this.buildResult(payParams, PaymentResultStatus.FAILED, '6001', '用户取消支付');
      }

    } catch (e) {
      Logger.error(TAG, 'Alipay pay error');
      let errMsg: string = '支付宝调起失败';
      if (e instanceof Error) {
        errMsg = e.message;
      }
      return this.buildResult(payParams, PaymentResultStatus.FAILED, 'SDK_ERROR', errMsg);
    }
  }
}
