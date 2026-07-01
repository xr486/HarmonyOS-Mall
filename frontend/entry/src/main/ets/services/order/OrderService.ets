import { DatabaseHelper } from '../../database/helper/DatabaseHelper';
import { CloudDBOrder } from '../../database/schema/CloudDBTypes';
import { Order, OrderItem, OrderStatus, Address } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'OrderService';

export class OrderService {
  private static instance: OrderService | null = null;
  private dbHelper: DatabaseHelper;

  private constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  static getInstance(): OrderService {
    if (!OrderService.instance) {
      OrderService.instance = new OrderService();
    }
    return OrderService.instance;
  }

  private convertToOrder(cloud: CloudDBOrder): Order {
    const itemsStr: string = cloud.items || '[]';
    const addressStr: string = cloud.address || '{}';
    const items: OrderItem[] = JSON.parse(itemsStr) as OrderItem[];
    const address: Address = JSON.parse(addressStr) as Address;
    const order: Order = {
      orderId: cloud.orderId || '',
      orderNo: cloud.orderNo || '',
      userId: cloud.userId || '',
      totalAmount: cloud.totalAmount || 0,
      status: (cloud.status ? parseInt(cloud.status) : OrderStatus.PENDING_PAYMENT) as OrderStatus,
      items: items,
      address: address,
      remark: cloud.remark || '',
      createdAt: cloud.createdAt || Date.now(),
      expireTime: cloud.expireTime || 0
    };
    return order;
  }

  private convertToCloudOrder(order: Order): CloudDBOrder {
    const cloud: CloudDBOrder = new CloudDBOrder();
    cloud.orderId = order.orderId;
    cloud.orderNo = order.orderNo;
    cloud.userId = order.userId;
    cloud.totalAmount = order.totalAmount;
    cloud.status = order.status.toString();
    cloud.items = JSON.stringify(order.items);
    cloud.address = JSON.stringify(order.address);
    cloud.paymentMethod = order.payment ? order.payment.method.toString() : '';
    cloud.paymentStatus = order.payment ? order.payment.status.toString() : '';
    cloud.remark = order.remark || '';
    cloud.createdAt = order.createdAt;
    cloud.paidAt = order.paidAt || 0;
    cloud.completedAt = order.completedAt || 0;
    cloud.expireTime = order.expireTime;
    return cloud;
  }

  async getAllOrders(userId: string): Promise<Order[]> {
    const db = this.dbHelper.getDatabase();
    if (!db) {
      return [];
    }
    const collection = db.collection(CloudDBOrder);
    const result: CloudDBOrder[] = await collection.query().equalTo('userId', userId).get();
    return result.map((item: CloudDBOrder) => this.convertToOrder(item));
  }

  async getOrderById(orderId: string): Promise<Order | null> {
    const db = this.dbHelper.getDatabase();
    if (!db) {
      return null;
    }
    const collection = db.collection(CloudDBOrder);
    const result: CloudDBOrder[] = await collection.query().equalTo('orderId', orderId).get();
    if (result.length > 0) {
      return this.convertToOrder(result[0]);
    }
    return null;
  }

  async createOrder(order: Order): Promise<void> {
    const db = this.dbHelper.getDatabase();
    if (!db) {
      return;
    }
    const cloudOrder: CloudDBOrder = this.convertToCloudOrder(order);
    const collection = db.collection(CloudDBOrder);
    await collection.upsert(cloudOrder);
    Logger.info(TAG, 'Order created: %{public}s', order.orderNo);
  }

  async updateOrderStatus(orderId: string, status: OrderStatus): Promise<void> {
    const db = this.dbHelper.getDatabase();
    if (!db) {
      return;
    }
    const collection = db.collection(CloudDBOrder);
    const result: CloudDBOrder[] = await collection.query().equalTo('orderId', orderId).get();
    if (result.length > 0) {
      const cloudOrder: CloudDBOrder = result[0];
      cloudOrder.status = status.toString();
      await collection.upsert(cloudOrder);
      Logger.info(TAG, 'Order status updated: %{public}s -> %{public}d', orderId, status);
    }
  }

  async cancelOrder(orderId: string): Promise<void> {
    await this.updateOrderStatus(orderId, OrderStatus.CANCELLED);
  }
}
