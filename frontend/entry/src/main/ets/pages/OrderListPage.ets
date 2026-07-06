import { OrderService } from '../services/order/OrderService';
import { Order, OrderItem, OrderStatus } from '../common/models';
import { Address } from '../common/models/Address';
import router from '@ohos.router';

function mapOrderStatus(statusStr: string): OrderStatus {
  const statusMap: Record<string, OrderStatus> = {
    'pending_payment': OrderStatus.PENDING_PAYMENT,
    'paid': OrderStatus.PENDING_SHIPMENT,
    'shipped': OrderStatus.PENDING_RECEIPT,
    'completed': OrderStatus.COMPLETED,
    'cancelled': OrderStatus.CANCELLED
  };
  const mapped: OrderStatus | undefined = statusMap[statusStr];
  return mapped !== undefined ? mapped : OrderStatus.PENDING_PAYMENT;
}

function getEmptyAddress(): Address {
  const now: number = Date.now();
  const addr: Address = {
    addressId: '',
    userId: '',
    name: '',
    phone: '',
    province: '',
    city: '',
    district: '',
    detail: '',
    isDefault: false,
    createdAt: now,
    updatedAt: now
  };
  return addr;
}

interface RouterPayParams {
  orderId: string;
  orderNo: string;
  amount: number;
}

@Entry
@Component
struct OrderListPage {
  @State orders: Order[] = [];
  @State isLoading: boolean = true;
  @State activeTab: number = -1;

  aboutToAppear(): void {
    this.loadOrders();
  }

  async loadOrders(): Promise<void> {
    this.isLoading = true;
    try {
      const service: OrderService = OrderService.getInstance();
      const allOrders: Order[] = await service.getAllOrders('default_user');
      const mappedOrders: Order[] = [];
      for (let i = 0; i < allOrders.length; i++) {
        const o: Order = allOrders[i];
        let orderStatus: OrderStatus = OrderStatus.PENDING_PAYMENT;
        const rawStatus: string | number = o.status as string | number;
        if (typeof rawStatus === 'string') {
          orderStatus = mapOrderStatus(rawStatus);
        } else {
          orderStatus = rawStatus as OrderStatus;
        }
        const orderAddress: Address = o.address ? o.address : getEmptyAddress();
        const mapped: Order = {
          orderId: o.orderId,
          orderNo: o.orderNo !== undefined ? o.orderNo : '',
          userId: o.userId !== undefined ? o.userId : '',
          totalAmount: o.totalAmount !== undefined ? o.totalAmount : 0,
          status: orderStatus,
          items: o.items !== undefined ? o.items : [],
          address: orderAddress,
          remark: o.remark,
          createdAt: o.createdAt !== undefined ? o.createdAt : Date.now(),
          expireTime: o.expireTime !== undefined ? o.expireTime : Date.now() + 1800000
        };
        mappedOrders.push(mapped);
      }
      this.orders = mappedOrders;
    } catch (e) {
      this.orders = [];
    }
    this.isLoading = false;
  }

  getFilteredOrders(): Order[] {
    if (this.activeTab === -1) {
      return this.orders;
    }
    return this.orders.filter((o: Order) => o.status === this.activeTab);
  }

  getStatusText(status: number): string {
    if (status === OrderStatus.PENDING_PAYMENT) { return '待付款'; }
    if (status === OrderStatus.PENDING_SHIPMENT) { return '待发货'; }
    if (status === OrderStatus.PENDING_RECEIPT) { return '待收货'; }
    if (status === OrderStatus.COMPLETED) { return '已完成'; }
    if (status === OrderStatus.CANCELLED) { return '已取消'; }
    return '未知';
  }

  getStatusColor(status: number): string {
    if (status === OrderStatus.PENDING_PAYMENT) { return '#FF4D4F'; }
    if (status === OrderStatus.CANCELLED) { return '#999'; }
    return '#52C41A';
  }

  goToPayment(order: Order): void {
    const params: RouterPayParams = {
      orderId: order.orderId,
      orderNo: order.orderNo,
      amount: order.totalAmount
    };
    router.pushUrl({
      url: 'pages/PaymentPage',
      params: params
    });
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(22)
          .onClick(() => { router.back(); })
        Text('我的订单')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('')
          .width(36)
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor(Color.White)

      Row() {
        Text('全部')
          .fontSize(14)
          .fontColor(this.activeTab === -1 ? '#FF4D4F' : '#333')
          .padding(8)
          .onClick(() => { this.activeTab = -1; })

        Text('待付款')
          .fontSize(14)
          .fontColor(this.activeTab === OrderStatus.PENDING_PAYMENT ? '#FF4D4F' : '#333')
          .padding(8)
          .onClick(() => { this.activeTab = OrderStatus.PENDING_PAYMENT; })

        Text('待收货')
          .fontSize(14)
          .fontColor(this.activeTab === OrderStatus.PENDING_RECEIPT ? '#FF4D4F' : '#333')
          .padding(8)
          .onClick(() => { this.activeTab = OrderStatus.PENDING_RECEIPT; })

        Text('已完成')
          .fontSize(14)
          .fontColor(this.activeTab === OrderStatus.COMPLETED ? '#FF4D4F' : '#333')
          .padding(8)
          .onClick(() => { this.activeTab = OrderStatus.COMPLETED; })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceAround)

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40)
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.getFilteredOrders().length === 0) {
        Column() {
          Text('暂无订单')
            .fontSize(16)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.getFilteredOrders(), (order: Order) => {
              Column() {
                Row() {
                  Text(`订单号: ${order.orderNo}`)
                    .fontSize(13)
                    .fontColor('#666')
                  Text(this.getStatusText(order.status))
                    .fontSize(13)
                    .fontColor(this.getStatusColor(order.status))
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)

                if (order.items && order.items.length > 0) {
                  ForEach(order.items.slice(0, 3), (item: OrderItem) => {
                    Row() {
                      Image(item.productImage)
                        .width(64)
                        .height(64)
                        .borderRadius(4)
                        .alt($r('app.media.app_icon'))
                      Column() {
                        Text(item.productName)
                          .fontSize(14)
                          .maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                        Text(`¥${item.price}  x${item.quantity}`)
                          .fontSize(13)
                          .fontColor('#999')
                          .margin({ top: 4 })
                      }
                      .layoutWeight(1)
                      .margin({ left: 10 })
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .margin({ top: 8 })
                  }, (item: OrderItem) => item.itemId)
                }

                Row() {
                  Text(`共 ${order.items ? order.items.length : 0} 件商品 合计: `)
                    .fontSize(13)
                    .fontColor('#666')
                  Text(`¥${order.totalAmount}`)
                    .fontSize(15)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FF4D4F')
                }
                .width('100%')
                .justifyContent(FlexAlign.End)
                .margin({ top: 10 })

                if (order.status === OrderStatus.PENDING_PAYMENT) {
                  Row() {
                    Button('取消订单')
                      .fontSize(13)
                      .height(32)
                      .backgroundColor('#f5f5f5')
                      .fontColor('#666')
                      .borderRadius(16)
                      .padding({ left: 16, right: 16 })
                    Button('去支付')
                      .fontSize(13)
                      .height(32)
                      .backgroundColor('#ff4d4f')
                      .fontColor(Color.White)
                      .borderRadius(16)
                      .padding({ left: 20, right: 20 })
                      .margin({ left: 12 })
                      .onClick(() => this.goToPayment(order))
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.End)
                  .margin({ top: 12 })
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Color.White)
              .borderRadius(10)
              .margin({ bottom: 8 })
            }, (order: Order) => order.orderId)
          }
          .padding(12)
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
  }
}
