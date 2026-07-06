import { OrderService } from '../services/order/OrderService';
import { Order, OrderStatus, OrderItem } from '../common/models';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { RouteConstants } from '../common/constants/RouteConstants';
import { PayPageParams } from '../common/models/PaymentTypes';
import { OrderRefreshUtil } from '../common/utils/OrderRefreshUtil';

interface TabItem {
  label: string;
  status: number;
}

interface OrderListPageParams {
  status?: number;
}

interface OrderDetailPageParams {
  orderId: string;
}

@Entry
@Component
struct OrderListPage {
  @State orders: Order[] = [];
  @State isLoading: boolean = true;
  @State activeTab: number = 0;
  @StorageLink(OrderRefreshUtil.getKey()) @Watch('onRefreshTriggered') refreshTrigger: number = 0;

  private tabs: TabItem[] = [
    { label: '全部', status: 0 },
    { label: '待付款', status: OrderStatus.PENDING_PAYMENT },
    { label: '待发货', status: OrderStatus.PENDING_SHIPMENT },
    { label: '待收货', status: OrderStatus.PENDING_RECEIPT },
    { label: '已完成', status: OrderStatus.COMPLETED },
    { label: '已取消', status: OrderStatus.CANCELLED }
  ];

  aboutToAppear(): void {
    const params: Object = router.getParams();
    if (params !== undefined) {
      const pageParams = params as OrderListPageParams;
      if (pageParams.status !== undefined) {
        for (let i: number = 0; i < this.tabs.length; i++) {
          if (this.tabs[i].status === pageParams.status) {
            this.activeTab = i;
            break;
          }
        }
      }
    }
    this.loadOrders();
  }

  onRefreshTriggered(): void {
    this.loadOrders();
  }

  async loadOrders(): Promise<void> {
    this.isLoading = true;
    try {
      const service: OrderService = OrderService.getInstance();
      const status: number = this.tabs[this.activeTab].status;
      const allOrders: Order[] = await service.getAllOrders('default_user', status === 0 ? undefined : status);
      this.orders = allOrders;
    } catch (e) {
      this.orders = [];
      promptAction.showToast({ message: '加载订单失败' });
    }
    this.isLoading = false;
  }

  onTabChanged(index: number): void {
    this.activeTab = index;
    this.loadOrders();
  }

  getStatusText(status: OrderStatus): string {
    if (status === OrderStatus.PENDING_PAYMENT) { return '待付款'; }
    if (status === OrderStatus.PENDING_SHIPMENT) { return '待发货'; }
    if (status === OrderStatus.PENDING_RECEIPT) { return '待收货'; }
    if (status === OrderStatus.COMPLETED) { return '已完成'; }
    if (status === OrderStatus.CANCELLED) { return '已取消'; }
    return '未知';
  }

  getStatusColor(status: OrderStatus): string {
    if (status === OrderStatus.PENDING_PAYMENT) { return '#FF4D4F'; }
    if (status === OrderStatus.PENDING_SHIPMENT) { return '#FAAD14'; }
    if (status === OrderStatus.PENDING_RECEIPT) { return '#1890FF'; }
    if (status === OrderStatus.COMPLETED) { return '#52C41A'; }
    if (status === OrderStatus.CANCELLED) { return '#999999'; }
    return '#999999';
  }

  goToDetail(order: Order): void {
    const params: OrderDetailPageParams = {
      orderId: order.orderId
    };
    router.pushUrl({
      url: RouteConstants.ORDER_DETAIL,
      params: params
    });
  }

  async cancelOrder(order: Order, index: number): Promise<void> {
    if (this.tabs[this.activeTab].status !== 0 && this.tabs[this.activeTab].status !== OrderStatus.CANCELLED) {
      this.orders.splice(index, 1);
    } else {
      order.status = OrderStatus.CANCELLED;
    }
    promptAction.showToast({ message: '订单已取消' });
    
    try {
      const service: OrderService = OrderService.getInstance();
      await service.cancelOrder(order.orderId);
    } catch (e) {
    }
  }

  async confirmReceipt(order: Order, index: number): Promise<void> {
    const originalStatus = order.status;
    if (this.tabs[this.activeTab].status !== 0 && this.tabs[this.activeTab].status !== OrderStatus.COMPLETED) {
      this.orders.splice(index, 1);
    } else {
      order.status = OrderStatus.COMPLETED;
    }
    promptAction.showToast({ message: '确认收货成功' });
    
    try {
      const service: OrderService = OrderService.getInstance();
      await service.confirmReceipt(order.orderId);
    } catch (e) {
      order.status = originalStatus;
    }
  }

  goToPayment(order: Order): void {
    const params: PayPageParams = {
      orderId: order.orderId,
      orderNo: order.orderNo,
      amount: order.totalAmount
    };
    router.pushUrl({
      url: RouteConstants.PAYMENT,
      params: params
    });
  }

  @Builder
  NavBar() {
    Row() {
      Text('‹')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .onClick(() => router.back())

      Text('我的订单')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text('')
        .width(36)
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }

  @Builder
  TabsBar() {
    Row() {
      ForEach(this.tabs, (tab: TabItem, index: number) => {
        Column() {
          Text(tab.label)
            .fontSize(14)
            .fontColor(this.activeTab === index ? '#FF4D4F' : '#333')

          if (this.activeTab === index) {
            Rect()
              .width(20)
              .height(3)
              .borderRadius(1.5)
              .fill('#FF4D4F')
              .margin({ top: 4 })
          } else {
            Blank()
              .height(7)
          }
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onTabChanged(index))
      })
    }
    .width('100%')
    .height(44)
    .backgroundColor(Color.White)
    .border({ width: { bottom: 0.5 }, color: '#EEEEEE' })
  }

  @Builder
  OrderItemView(order: Order, index: number) {
    Column() {
      Row() {
        Text(this.getStatusText(order.status))
          .fontSize(13)
          .fontColor(this.getStatusColor(order.status))
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ bottom: 8 })

      if (order.items && order.items.length > 0) {
        Row() {
          Image(order.items[0].productImage || '')
            .width(72)
            .height(72)
            .objectFit(ImageFit.Cover)
            .borderRadius(6)
            .alt($r('app.media.app_icon'))

          Column() {
            Text(order.items[0].productName || '')
              .fontSize(14)
              .fontColor('#333')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')

            Blank()
              .layoutWeight(1)

            Row() {
              Text(`¥${order.items[0].price.toFixed(2)}`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333')
                .layoutWeight(1)

              Text(`x${order.items[0].quantity}`)
                .fontSize(13)
                .fontColor('#999')
            }
            .width('100%')
          }
          .layoutWeight(1)
          .height(72)
          .padding({ left: 10 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .margin({ bottom: 8 })
      }

      if (order.items && order.items.length > 1) {
        Text(`共${order.items.length}件商品，合计¥${order.totalAmount.toFixed(2)}`)
          .fontSize(12)
          .fontColor('#999')
          .width('100%')
          .textAlign(TextAlign.End)
          .margin({ bottom: 8 })
      }

      if (order.items.length <= 1) {
        Row() {
          Text('实付款')
            .fontSize(12)
            .fontColor('#666')
          Text(`¥${order.totalAmount.toFixed(2)}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: 8 })
      }

      Row() {
        Blank()
          .layoutWeight(1)

        if (order.status === OrderStatus.PENDING_PAYMENT) {
          Button('取消订单')
            .fontSize(13)
            .fontColor('#666')
            .backgroundColor('#F5F5F5')
            .borderRadius(16)
            .height(32)
            .padding({ left: 16, right: 16 })
            .margin({ right: 8 })
            .onClick(() => this.cancelOrder(order, index))
        }

        if (order.status === OrderStatus.PENDING_PAYMENT) {
          Button('去支付')
            .fontSize(13)
            .fontColor(Color.White)
            .backgroundColor('#FF4D4F')
            .borderRadius(16)
            .height(32)
            .padding({ left: 16, right: 16 })
            .onClick(() => this.goToPayment(order))
        }

        if (order.status === OrderStatus.PENDING_RECEIPT) {
          Button('确认收货')
            .fontSize(13)
            .fontColor(Color.White)
            .backgroundColor('#FF4D4F')
            .borderRadius(16)
            .height(32)
            .padding({ left: 16, right: 16 })
            .onClick(() => this.confirmReceipt(order, index))
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ top: 10 })
    .onClick(() => this.goToDetail(order))
  }

  build() {
    Column() {
      this.NavBar()
      this.TabsBar()

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#FF4D4F')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 12 })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else if (this.orders.length === 0) {
        Column() {
          Text('暂无订单')
            .fontSize(16)
            .fontColor('#999')
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else {
        Scroll() {
          Column() {
            ForEach(this.orders, (order: Order, index: number) => {
              this.OrderItemView(order, index)
            }, (order: Order) => order.orderId)
          }
          .width('100%')
          .padding({ left: 12, right: 12, bottom: 12 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
