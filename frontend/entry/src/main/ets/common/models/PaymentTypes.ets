export enum PaymentMethodType {
  ALIPAY = 'alipay',
  WECHAT_PAY = 'wechat',
  HUAWEI_PAY = 'huawei'
}

export enum PaymentResultStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  SUCCESS = 'success',
  FAILED = 'failed',
  CLOSED = 'closed',
  REFUNDED = 'refunded'
}

export interface PayRequestParams {
  orderId: string;
  paymentMethod: PaymentMethodType;
}

export interface PayResponseParams {
  paymentId: string;
  orderId: string;
  paymentMethod: PaymentMethodType;
  payParams: Record<string, string>;
  orderStr?: string;
}

export interface PaymentResult {
  paymentId: string;
  orderId: string;
  orderNo: string;
  status: PaymentResultStatus;
  transactionNo?: string;
  errorCode?: string;
  errorMsg?: string;
  paidAmount?: number;
  paidAt?: number;
}

export interface PaymentChannelInfo {
  method: PaymentMethodType;
  name: string;
  icon: string;
  desc: string;
  enabled: boolean;
}

export const PAYMENT_CHANNELS: PaymentChannelInfo[] = [
  {
    method: PaymentMethodType.ALIPAY,
    name: '支付宝',
    icon: 'alipay_icon',
    desc: '推荐使用支付宝沙箱环境',
    enabled: true
  },
  {
    method: PaymentMethodType.WECHAT_PAY,
    name: '微信支付',
    icon: 'wechat_icon',
    desc: 'Mock环境，用于流程演示',
    enabled: true
  },
  {
    method: PaymentMethodType.HUAWEI_PAY,
    name: '华为支付',
    icon: 'huawei_icon',
    desc: 'Mock环境，用于流程演示',
    enabled: true
  }
];
