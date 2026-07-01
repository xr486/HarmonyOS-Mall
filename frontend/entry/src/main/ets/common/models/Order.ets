import { Address } from './Address';
import { PaymentMethod, PaymentStatus, PaymentInfo } from './Payment';

export enum OrderStatus {
  PENDING_PAYMENT = 0,
  PENDING_SHIPMENT = 1,
  PENDING_RECEIPT = 2,
  COMPLETED = 3,
  CANCELLED = 4
}

export interface OrderItem {
  itemId: string;
  productId: string;
  productName: string;
  productImage: string;
  price: number;
  quantity: number;
  spec?: string;
}

export interface Order {
  orderId: string;
  orderNo: string;
  userId: string;
  totalAmount: number;
  status: OrderStatus;
  items: OrderItem[];
  address: Address;
  payment?: PaymentInfo;
  remark?: string;
  createdAt: number;
  paidAt?: number;
  completedAt?: number;
  expireTime: number;
}