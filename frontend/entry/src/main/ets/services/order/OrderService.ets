import { HttpUtil, ApiResponse, CreateOrderBody } from '../../common/utils/http/HttpUtil';
import { Order, OrderItem, OrderStatus } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'OrderService';

class OrderObj {
  orderId: string = '';
  orderNo: string = '';
  userId: string = '';
  totalAmount: number = 0;
  status: OrderStatus = OrderStatus.PENDING_PAYMENT;
  items: OrderItem[] = [];
  address: string = '';
  addressId: string = '';
  remark: string = '';
  createdAt: number = 0;
  updatedAt: number = 0;
  paidAt?: number = undefined;
  completedAt?: number = undefined;
  expireTime: number = 0;
}

/** 字符串状态 -> 枚举映射 */
function mapStatus(statusStr: string): OrderStatus {
  if (statusStr === 'pending_payment') return OrderStatus.PENDING_PAYMENT;
  if (statusStr === 'pending_shipment') return OrderStatus.PENDING_SHIPMENT;
  if (statusStr === 'pending_receipt') return OrderStatus.PENDING_RECEIPT;
  if (statusStr === 'completed') return OrderStatus.COMPLETED;
  if (statusStr === 'cancelled') return OrderStatus.CANCELLED;
  return OrderStatus.PENDING_PAYMENT;
}

function buildOrderItemFromJson(it: Record<string, Object>): OrderItem {
  return {
    itemId: (it['itemId'] as string) ?? '',
    productId: (it['productId'] as string) ?? '',
    productName: (it['productName'] as string) ?? '',
    productImage: (it['productImage'] as string) ?? '',
    price: (it['price'] as number) ?? 0,
    quantity: (it['quantity'] as number) ?? 1,
    spec: (it['specs'] as string) ?? ''
  };
}

function buildOrderFromJson(data: Object): Order {
  const raw: Record<string, Object> = JSON.parse(JSON.stringify(data)) as Record<string, Object>;
  const out: OrderObj = new OrderObj();
  out.orderId = (raw['orderId'] as string) ?? '';
  out.orderNo = (raw['orderNo'] as string) ?? '';
  out.userId = (raw['userId'] as string) ?? '';
  out.totalAmount = (raw['totalAmount'] as number) ?? 0;
  out.status = mapStatus((raw['status'] as string) ?? 'pending_payment');
  out.address = (raw['addressSnapshot'] as string) ?? '';
  out.addressId = (raw['addressId'] as string) ?? '';
  out.remark = (raw['remark'] as string) ?? '';
  out.createdAt = (raw['createdAt'] as number) ?? 0;
  out.updatedAt = (raw['updatedAt'] as number) ?? 0;
  out.paidAt = (raw['paidAt'] as number) ?? undefined;
  out.completedAt = (raw['completedAt'] as number) ?? undefined;
  out.expireTime = (raw['expireTime'] as number) ?? 0;

  // 解析订单商品明细
  const itemsRaw: Object[] = raw['items'] as Object[] ?? [];
  const items: OrderItem[] = [];
  for (let i: number = 0; i < itemsRaw.length; i++) {
    const it: Record<string, Object> = JSON.parse(JSON.stringify(itemsRaw[i])) as Record<string, Object>;
    items.push(buildOrderItemFromJson(it));
  }
  out.items = items;
  return out as Order;
}

export class OrderService {
  private static instance: OrderService | null = null;

  private constructor() {
  }

  static getInstance(): OrderService {
    if (!OrderService.instance) {
      OrderService.instance = new OrderService();
    }
    return OrderService.instance;
  }

  private statusToString(status: number): string {
    if (status === OrderStatus.PENDING_PAYMENT) return 'pending_payment';
    if (status === OrderStatus.PENDING_SHIPMENT) return 'pending_shipment';
    if (status === OrderStatus.PENDING_RECEIPT) return 'pending_receipt';
    if (status === OrderStatus.COMPLETED) return 'completed';
    if (status === OrderStatus.CANCELLED) return 'cancelled';
    return 'pending_payment';
  }

  async getAllOrders(userId: string, status?: number): Promise<Order[]> {
    try {
      let url: string = '/orders';
      if (status !== undefined && status !== null) {
        url = url + '?status=' + this.statusToString(status);
      }
      const res: ApiResponse<Object[]> = await HttpUtil.get(url);
      if (res.code === 200 && res.data) {
        Logger.info(TAG, 'getAllOrders got %{public}d orders', res.data.length);
        const orders: Order[] = [];
        for (let i: number = 0; i < res.data.length; i++) {
          orders.push(buildOrderFromJson(res.data[i]));
        }
        return orders;
      }
      return [];
    } catch (e) {
      Logger.error(TAG, 'getAllOrders error: %{public}s', JSON.stringify(e));
      return [];
    }
  }

  async getOrderDetail(orderId: string): Promise<Order | null> {
    try {
      const res: ApiResponse<Object> = await HttpUtil.get('/orders/' + orderId);
      if (res.code === 200 && res.data) {
        const raw: Record<string, Object> = JSON.parse(JSON.stringify(res.data)) as Record<string, Object>;
        const orderRaw: Record<string, Object> = raw['order'] as Record<string, Object>;
        const order: Order = buildOrderFromJson(orderRaw);
        const itemsRaw: Object[] = raw['items'] as Object[] ?? [];
        const items: OrderItem[] = [];
        for (let i: number = 0; i < itemsRaw.length; i++) {
          const it: Record<string, Object> = JSON.parse(JSON.stringify(itemsRaw[i])) as Record<string, Object>;
          const item: OrderItem = {
            itemId: (it['itemId'] as string) ?? '',
            productId: (it['productId'] as string) ?? '',
            productName: (it['productName'] as string) ?? '',
            productImage: (it['productImage'] as string) ?? '',
            price: (it['price'] as number) ?? 0,
            quantity: (it['quantity'] as number) ?? 1
          };
          items.push(item);
        }
        order.items = items;
        Logger.info(TAG, 'getOrderDetail: %{public}s, %{public}d items', order.orderNo, items.length);
        return order;
      }
      return null;
    } catch (e) {
      Logger.error(TAG, 'getOrderDetail error: %{public}s', JSON.stringify(e));
      return null;
    }
  }

  async createOrder(cartIds: string[], addressId: string, remark?: string): Promise<Order | null> {
    try {
      const body: CreateOrderBody = new CreateOrderBody();
      body.cartIds = cartIds;
      body.addressId = addressId;
      if (remark && remark.length > 0) {
        body.remark = remark;
      }
      const res: ApiResponse<Object> = await HttpUtil.post('/orders', body);
      Logger.info(TAG, 'createOrder code=%{public}d', res.code);
      if (res.code === 200 && res.data) {
        return buildOrderFromJson(res.data);
      }
      return null;
    } catch (e) {
      Logger.error(TAG, 'createOrder error: %{public}s', JSON.stringify(e));
      return null;
    }
  }

  async cancelOrder(orderId: string): Promise<boolean> {
    try {
      const res: ApiResponse<Object> = await HttpUtil.put('/orders/' + orderId + '/cancel');
      Logger.info(TAG, 'cancelOrder code=%{public}d', res.code);
      return res.code === 200;
    } catch (e) {
      Logger.error(TAG, 'cancelOrder error: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  async confirmReceipt(orderId: string): Promise<boolean> {
    try {
      const res: ApiResponse<Object> = await HttpUtil.put('/orders/' + orderId + '/confirm');
      Logger.info(TAG, 'confirmReceipt code=%{public}d', res.code);
      return res.code === 200;
    } catch (e) {
      Logger.error(TAG, 'confirmReceipt error: %{public}s', JSON.stringify(e));
      return false;
    }
  }
}
