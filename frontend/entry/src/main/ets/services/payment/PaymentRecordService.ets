import { http } from '@kit.NetworkKit';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'PaymentRecordService';
const BASE_URL = 'http://10.0.2.2:8080/api/v1/payment';

interface ApiResponse<T> {
  code: number;
  data: T;
  message: string;
}

export interface PaymentRecord {
  paymentId: string;
  orderId: string;
  orderNo: string;
  amount: number;
  method: string;
  methodText: string;
  status: string;
  statusText: string;
  transactionNo: string;
  paidAt: number;
  createdAt: number;
}

export interface RefundRecord {
  refundId: string;
  paymentId: string;
  orderId: string;
  refundNo: string;
  transactionNo: string;
  amount: number;
  reason: string;
  status: string;
  createdAt: number;
}

export class PaymentRecordService {
  private static instance: PaymentRecordService | null = null;

  static getInstance(): PaymentRecordService {
    if (!PaymentRecordService.instance) {
      PaymentRecordService.instance = new PaymentRecordService();
    }
    return PaymentRecordService.instance;
  }

  async getPaymentHistory(userId: string = 'default_user'): Promise<PaymentRecord[]> {
    let req: http.HttpRequest | null = null;
    try {
      req = http.createHttp();
      const resp = await req.request(`${BASE_URL}/records`, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'X-User-Id': userId
        }
      });
      if (resp.responseCode === 200) {
        const data: ApiResponse<PaymentRecord[]> = JSON.parse(resp.result as string) as ApiResponse<PaymentRecord[]>;
        if (data.code === 0 && data.data) {
          return data.data;
        }
      }
      return [];
    } catch (e) {
      Logger.error(TAG, '获取支付记录失败');
      return [];
    } finally {
      if (req) {
        req.destroy();
      }
    }
  }

  async getOrderPaymentHistory(orderId: string, userId: string = 'default_user'): Promise<PaymentRecord[]> {
    let req: http.HttpRequest | null = null;
    try {
      req = http.createHttp();
      const resp = await req.request(`${BASE_URL}/records/${orderId}`, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'X-User-Id': userId
        }
      });
      if (resp.responseCode === 200) {
        const data: ApiResponse<PaymentRecord[]> = JSON.parse(resp.result as string) as ApiResponse<PaymentRecord[]>;
        if (data.code === 0 && data.data) {
          return data.data;
        }
      }
      return [];
    } catch (e) {
      Logger.error(TAG, '获取订单支付记录失败');
      return [];
    } finally {
      if (req) {
        req.destroy();
      }
    }
  }

  async createRefund(paymentId: string, amount: number, reason: string, userId: string = 'default_user'): Promise<RefundRecord | null> {
    let req: http.HttpRequest | null = null;
    try {
      req = http.createHttp();
      const resp = await req.request(`${BASE_URL}/refund`, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'X-User-Id': userId
        },
        extraData: JSON.stringify({
          paymentId: paymentId,
          amount: amount,
          reason: reason
        })
      });
      if (resp.responseCode === 200) {
        const data: ApiResponse<RefundRecord> = JSON.parse(resp.result as string) as ApiResponse<RefundRecord>;
        if (data.code === 0 && data.data) {
          return data.data;
        }
      }
      return null;
    } catch (e) {
      Logger.error(TAG, '创建退款失败');
      return null;
    } finally {
      if (req) {
        req.destroy();
      }
    }
  }

  async getRefundRecords(orderId: string, userId: string = 'default_user'): Promise<RefundRecord[]> {
    let req: http.HttpRequest | null = null;
    try {
      req = http.createHttp();
      const resp = await req.request(`${BASE_URL}/refund/${orderId}`, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'X-User-Id': userId
        }
      });
      if (resp.responseCode === 200) {
        const data: ApiResponse<RefundRecord[]> = JSON.parse(resp.result as string) as ApiResponse<RefundRecord[]>;
        if (data.code === 0 && data.data) {
          return data.data;
        }
      }
      return [];
    } catch (e) {
      Logger.error(TAG, '获取退款记录失败');
      return [];
    } finally {
      if (req) {
        req.destroy();
      }
    }
  }

  async confirmRefund(refundId: string, userId: string = 'default_user'): Promise<boolean> {
    let req: http.HttpRequest | null = null;
    try {
      req = http.createHttp();
      const resp = await req.request(`${BASE_URL}/refund/${refundId}/confirm`, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'X-User-Id': userId
        }
      });
      if (resp.responseCode === 200) {
        const data: ApiResponse<string> = JSON.parse(resp.result as string) as ApiResponse<string>;
        return data.code === 0;
      }
      return false;
    } catch (e) {
      Logger.error(TAG, '确认退款失败');
      return false;
    } finally {
      if (req) {
        req.destroy();
      }
    }
  }
}
