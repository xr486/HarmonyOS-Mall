import { HttpUtil, ApiResponse } from '../../common/utils/http/HttpUtil';
import { PayResponseParams, PayRequestParams, PaymentResult, PaymentMethodType, PaymentResultStatus } from '../../common/models/PaymentTypes';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'PaymentService';

interface ServerPayResponse {
  paymentId: string;
  orderId: string;
  paymentMethod: string;
  payParams: Record<string, string>;
  orderStr?: string;
}

interface ServerPaymentResult {
  paymentId: string;
  orderId: string;
  orderNo: string;
  status: string;
  transactionNo?: string;
  errorCode?: string;
  errorMsg?: string;
  paidAmount?: number;
  paidAt?: number;
}

interface ReportSyncBody {
  resultJson: string;
}

interface SyncResultData {
  status: string;
  transactionNo: string;
  errorCode: string;
  errorMsg: string;
}

export class PaymentService {
  private static instance: PaymentService | null = null;

  private constructor() {
  }

  static getInstance(): PaymentService {
    if (!PaymentService.instance) {
      PaymentService.instance = new PaymentService();
    }
    return PaymentService.instance;
  }

  async requestPayParams(orderId: string, method: PaymentMethodType): Promise<PayResponseParams | null> {
    try {
      const body: PayRequestParams = {
        orderId: orderId,
        paymentMethod: method
      };
      const res: ApiResponse<ServerPayResponse> = await HttpUtil.post('/payment/pay', body);
      if (res.code === 200 && res.data) {
        Logger.info(TAG, 'Get pay params success, paymentId: %{public}s', res.data.paymentId);
        let payMethod: PaymentMethodType = PaymentMethodType.ALIPAY;
        if (res.data.paymentMethod === PaymentMethodType.WECHAT_PAY) {
          payMethod = PaymentMethodType.WECHAT_PAY;
        } else if (res.data.paymentMethod === PaymentMethodType.HUAWEI_PAY) {
          payMethod = PaymentMethodType.HUAWEI_PAY;
        }
        const result: PayResponseParams = {
          paymentId: res.data.paymentId,
          orderId: res.data.orderId,
          paymentMethod: payMethod,
          payParams: res.data.payParams,
          orderStr: res.data.orderStr
        };
        return result;
      }
      Logger.error(TAG, 'Get pay params failed: code=%{public}d, msg=%{public}s', res.code, res.message);
      return null;
    } catch (e) {
      Logger.error(TAG, 'requestPayParams error');
      return null;
    }
  }

  async reportSyncResult(paymentId: string, result: PaymentResult): Promise<boolean> {
    try {
      const statusStr: string = result.status.toString();
      const txNoStr: string = result.transactionNo !== undefined ? result.transactionNo : '';
      const errCodeStr: string = result.errorCode !== undefined ? result.errorCode : '';
      const errMsgStr: string = result.errorMsg !== undefined ? result.errorMsg : '';
      const syncData: SyncResultData = {
        status: statusStr,
        transactionNo: txNoStr,
        errorCode: errCodeStr,
        errorMsg: errMsgStr
      };
      const body: ReportSyncBody = {
        resultJson: JSON.stringify(syncData)
      };
      const res: ApiResponse<Object> = await HttpUtil.post('/payment/sync-result/' + paymentId, body);
      return res.code === 200;
    } catch (e) {
      Logger.error(TAG, 'reportSyncResult error');
      return false;
    }
  }

  async queryPaymentStatus(orderId: string): Promise<PaymentResult> {
    const pendingResult: PaymentResult = {
      paymentId: '',
      orderId: orderId,
      orderNo: '',
      status: PaymentResultStatus.PENDING
    };
    try {
      const res: ApiResponse<ServerPaymentResult> = await HttpUtil.get('/payment/query/' + orderId);
      if (res.code === 200 && res.data) {
        return this.mapServerResult(res.data);
      }
      return pendingResult;
    } catch (e) {
      Logger.error(TAG, 'queryPaymentStatus error');
      return pendingResult;
    }
  }

  async mockPaySuccess(orderNo: string): Promise<boolean> {
    try {
      const res: ApiResponse<string> = await HttpUtil.post('/payment/mock/success/' + orderNo);
      return res.code === 200;
    } catch (e) {
      Logger.error(TAG, 'mockPaySuccess error');
      return false;
    }
  }

  private mapServerResult(server: ServerPaymentResult): PaymentResult {
    let status: PaymentResultStatus = PaymentResultStatus.PENDING;
    switch (server.status) {
      case 'success':
        status = PaymentResultStatus.SUCCESS;
        break;
      case 'failed':
        status = PaymentResultStatus.FAILED;
        break;
      case 'processing':
        status = PaymentResultStatus.PROCESSING;
        break;
      case 'closed':
        status = PaymentResultStatus.CLOSED;
        break;
      case 'refunded':
        status = PaymentResultStatus.REFUNDED;
        break;
      default:
        status = PaymentResultStatus.PENDING;
    }
    const result: PaymentResult = {
      paymentId: server.paymentId,
      orderId: server.orderId,
      orderNo: server.orderNo,
      status: status,
      transactionNo: server.transactionNo,
      errorCode: server.errorCode,
      errorMsg: server.errorMsg,
      paidAmount: server.paidAmount,
      paidAt: server.paidAt
    };
    return result;
  }
}
