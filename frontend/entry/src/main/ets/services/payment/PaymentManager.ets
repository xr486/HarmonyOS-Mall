import { IPaymentStrategy } from './IPaymentStrategy';
import { AlipayStrategy } from './AlipayStrategy';
import { WechatPayStrategy } from './WechatPayStrategy';
import { HuaweiPayStrategy } from './HuaweiPayStrategy';
import { PayResponseParams, PaymentResult, PaymentResultStatus, PaymentMethodType } from '../../common/models/PaymentTypes';
import { Logger } from '../../common/utils/logger/Logger';
import { PaymentService } from './PaymentService';

const TAG = 'PaymentManager';

export class PaymentManager {
  private static instance: PaymentManager | null = null;
  private strategyMap: Map<string, IPaymentStrategy> = new Map();
  private paymentService: PaymentService = PaymentService.getInstance();

  private constructor() {
    this.registerStrategy(new AlipayStrategy());
    this.registerStrategy(new WechatPayStrategy());
    this.registerStrategy(new HuaweiPayStrategy());
  }

  static getInstance(): PaymentManager {
    if (!PaymentManager.instance) {
      PaymentManager.instance = new PaymentManager();
    }
    return PaymentManager.instance;
  }

  private registerStrategy(strategy: IPaymentStrategy): void {
    this.strategyMap.set(strategy.method, strategy);
  }

  getStrategy(method: string): IPaymentStrategy | null {
    const s: IPaymentStrategy | undefined = this.strategyMap.get(method);
    return s !== undefined ? s : null;
  }

  async pay(orderId: string, method: PaymentMethodType): Promise<PaymentResult> {
    Logger.info(TAG, 'Starting payment, orderId: %{public}s, method: %{public}s', orderId, method);

    const strategy: IPaymentStrategy | null = this.getStrategy(method);
    if (strategy === null) {
      Logger.error(TAG, 'Payment method not supported: %{public}s', method);
      const failResult: PaymentResult = {
        paymentId: '',
        orderId: orderId,
        orderNo: '',
        status: PaymentResultStatus.FAILED,
        errorCode: 'METHOD_NOT_SUPPORTED',
        errorMsg: '不支持的支付方式'
      };
      return failResult;
    }

    try {
      Logger.info(TAG, 'Requesting pay params from server...');
      const payParams: PayResponseParams | null = await this.paymentService.requestPayParams(orderId, method);
      if (payParams === null) {
        Logger.error(TAG, 'Failed to get pay params from server');
        const failResult: PaymentResult = {
          paymentId: '',
          orderId: orderId,
          orderNo: '',
          status: PaymentResultStatus.FAILED,
          errorCode: 'GET_PARAMS_FAILED',
          errorMsg: '获取支付参数失败'
        };
        return failResult;
      }

      Logger.info(TAG, 'Invoking payment SDK...');
      const syncResult: PaymentResult = await strategy.pay(payParams);

      await this.paymentService.reportSyncResult(payParams.paymentId, syncResult);

      if (syncResult.status === PaymentResultStatus.PROCESSING) {
        Logger.info(TAG, 'Payment is processing, starting polling...');
        return await this.pollPaymentResult(orderId, 0);
      }

      return syncResult;
    } catch (e) {
      Logger.error(TAG, 'Payment error');
      let errMsg: string = '支付异常';
      if (e instanceof Error) {
        errMsg = e.message;
      }
      const failResult: PaymentResult = {
        paymentId: '',
        orderId: orderId,
        orderNo: '',
        status: PaymentResultStatus.FAILED,
        errorCode: 'PAY_ERROR',
        errorMsg: errMsg
      };
      return failResult;
    }
  }

  private async pollPaymentResult(orderId: string, attempt: number): Promise<PaymentResult> {
    const maxAttempts: number = 12;
    const interval: number = 2500;

    if (attempt >= maxAttempts) {
      Logger.warn(TAG, 'Polling timeout after %{public}d attempts', maxAttempts);
      const timeoutResult: PaymentResult = {
        paymentId: '',
        orderId: orderId,
        orderNo: '',
        status: PaymentResultStatus.PROCESSING,
        errorMsg: '支付结果确认中，请稍后查看订单状态'
      };
      return timeoutResult;
    }

    await new Promise<void>(resolve => setTimeout(resolve, interval));

    Logger.info(TAG, 'Polling payment status, attempt: %{public}d', attempt + 1);
    const result: PaymentResult = await this.paymentService.queryPaymentStatus(orderId);

    if (result.status === PaymentResultStatus.SUCCESS) {
      Logger.info(TAG, 'Payment success confirmed by server');
      return result;
    } else if (result.status === PaymentResultStatus.FAILED) {
      Logger.info(TAG, 'Payment failed confirmed by server');
      return result;
    }

    return this.pollPaymentResult(orderId, attempt + 1);
  }
}
