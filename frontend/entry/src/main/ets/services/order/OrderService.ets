import { HttpUtil, ApiResponse, CreateOrderBody } from '../../common/utils/http/HttpUtil';
import { Order } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'OrderService';

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

  async getAllOrders(userId: string): Promise<Order[]> {
    try {
      const res: ApiResponse<Order[]> = await HttpUtil.get('/orders');
      if (res.code === 200 && res.data) {
        return res.data;
      }
      return [];
    } catch (e) {
      Logger.error(TAG, 'getAllOrders error: %{public}s', JSON.stringify(e));
      return [];
    }
  }

  async getOrderById(orderId: string): Promise<Order | null> {
    try {
      const res: ApiResponse<Order> = await HttpUtil.get('/orders/' + orderId);
      if (res.code === 200) {
        return res.data;
      }
      return null;
    } catch (e) {
      Logger.error(TAG, 'getOrderById error: %{public}s', JSON.stringify(e));
      return null;
    }
  }

  async createOrder(order: Order): Promise<boolean> {
    try {
      const body: CreateOrderBody = new CreateOrderBody();
      body.totalAmount = order.totalAmount;
      body.items = order.items;
      body.address = order.address;
      body.remark = order.remark || '';
      const res: ApiResponse<Object> = await HttpUtil.post('/orders', body);
      if (res.code === 200) {
        Logger.info(TAG, 'Order created: %{public}s', order.orderNo);
        return true;
      }
      return false;
    } catch (e) {
      Logger.error(TAG, 'createOrder error: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  async cancelOrder(orderId: string): Promise<boolean> {
    try {
      const res: ApiResponse<Object> = await HttpUtil.put('/orders/' + orderId + '/cancel');
      if (res.code === 200) {
        Logger.info(TAG, 'Order cancelled: %{public}s', orderId);
        return true;
      }
      return false;
    } catch (e) {
      Logger.error(TAG, 'cancelOrder error: %{public}s', JSON.stringify(e));
      return false;
    }
  }
}
