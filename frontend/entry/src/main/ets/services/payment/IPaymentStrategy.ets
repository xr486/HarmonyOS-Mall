import { PayResponseParams, PaymentResult, PaymentResultStatus } from '../../common/models/PaymentTypes';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'IPaymentStrategy';

export interface IPaymentStrategy {
  readonly method: string;

  pay(payParams: PayResponseParams): Promise<PaymentResult>;
}

export abstract class BasePaymentStrategy implements IPaymentStrategy {
  abstract readonly method: string;

  abstract pay(payParams: PayResponseParams): Promise<PaymentResult>;

  protected buildResult(payParams: PayResponseParams, status: PaymentResultStatus, errorCode?: string, errorMsg?: string): PaymentResult {
    return {
      paymentId: payParams.paymentId,
      orderId: payParams.orderId,
      orderNo: '',
      status: status,
      errorCode: errorCode,
      errorMsg: errorMsg
    };
  }

  protected buildSuccessResult(payParams: PayResponseParams, transactionNo?: string): PaymentResult {
    const result = this.buildResult(payParams, PaymentResultStatus.SUCCESS);
    result.transactionNo = transactionNo;
    result.paidAmount = payParams.payParams['amount'] !== undefined ? Number(payParams.payParams['amount']) : undefined;
    result.paidAt = Date.now();
    return result;
  }

  protected async simulateSdkDelay(ms: number = 1500): Promise<void> {
    return new Promise<void>(resolve => setTimeout(resolve, ms));
  }
}
