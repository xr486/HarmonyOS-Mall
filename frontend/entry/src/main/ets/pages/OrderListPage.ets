import { OrderService } from '../services/order/OrderService';
import { Order, OrderStatus, OrderItem } from '../common/models';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface TabItem {
  label: string;
  status: number;
}

@Entry
@Component
struct OrderListPage {
  @State orders: Order[] = [];
  @State isLoading: boolean = true;
  @State activeTab: number = 0;

  private tabs: TabItem[] = [
    { label: '全部', status: 0 },
    { label: '待付款', status: OrderStatus.PENDING_PAYMENT },
    { label: '待发货', status: OrderStatus.PENDING_SHIPMENT },
    { label: '待收货', status: OrderStatus.PENDING_RECEIPT },
    { label: '已完成', status: OrderStatus.COMPLETED },
    { label: '已取消', status: OrderStatus.CANCELLED }
  ];

  aboutToAppear(): void {
    const params: Record<string, Object> = router.getParams() as Record<string, Object>;
    if (params && params['status'] !== undefined) {
      const status: number = params['status'] as number;
      for (let i: number = 0; i < this.tabs.length; i++) {
        if (this.tabs[i].status === status) {
          this.activeTab = i;
          break;
        }
      }
    }
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
    if (status === OrderStatus.CANCELLED) { return '#999'; }
    return '#999';
  }

  getItemCount(order: Order): number {
    if (!order.items || order.items.length === 0) {
      return 0;
    }
    let count: number = 0;
    for (let i: number = 0; i < order.items.length; i++) {
      count += order.items[i].quantity;
    }
    return count;
  }

  goToDetail(orderId: string): void {
    router.pushUrl({
      url: 'pages/OrderDetailPage',
      params: { orderId: orderId }
    });
  }

  build() {
    Column() {
      NavBar({ onBack: () => router.back() })

      TabBar({
        tabs: this.tabs,
        activeIndex: this.activeTab,
        onChange: (idx: number) => this.onTabChanged(idx)
      })

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#FF4D4F')
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else if (this.orders.length === 0) {
        Column() {
          Text('暂无订单')
            .fontSize(16)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else {
        Scroll() {
          Column() {
            ForEach(this.orders, (order: Order) => {
              OrderCard({
                order: order,
                onCancel: () => this.cancelOrder(order.orderId),
                onConfirm: () => this.confirmReceipt(order.orderId),
                onDetail: () => this.goToDetail(order.orderId)
              })
            }, (order: Order) => order.orderId)
          }
          .padding({ left: 12, right: 12, top: 0, bottom: 12 })
          .width('100%')
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

  async cancelOrder(orderId: string): Promise<void> {
    const service: OrderService = OrderService.getInstance();
    const success: boolean = await service.cancelOrder(orderId);
    if (success) {
      promptAction.showToast({ message: '订单已取消' });
      this.loadOrders();
    } else {
      promptAction.showToast({ message: '取消失败，请重试' });
    }
  }

  async confirmReceipt(orderId: string): Promise<void> {
    const service: OrderService = OrderService.getInstance();
    const success: boolean = await service.confirmReceipt(orderId);
    if (success) {
      promptAction.showToast({ message: '确认收货成功' });
      this.loadOrders();
    } else {
      promptAction.showToast({ message: '操作失败，请重试' });
    }
  }
}

@Component
struct NavBar {
  onBack?: VoidCallback;

  build() {
    Row() {
      Text('‹')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .onClick(() => { this.onBack?.(); })

      Text('我的订单')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Row()
        .width(36)
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16, top: 12 })
    .backgroundColor(Color.White)
  }
}

@Component
struct TabBar {
  @Prop tabs: TabItem[] = [];
  @Prop activeIndex: number = 0;
  onChange?: (index: number) => void;

  build() {
    Row() {
      ForEach(this.tabs, (tab: TabItem, index: number) => {
        Column() {
          Text(tab.label)
            .fontSize(13)
            .fontColor(this.activeIndex === index ? '#FF4D4F' : '#333')
            .fontWeight(this.activeIndex === index ? FontWeight.Medium : FontWeight.Normal)
            .padding({ top: 6, bottom: 4 })

          Row()
            .width(16)
            .height(3)
            .borderRadius(2)
            .backgroundColor(this.activeIndex === index ? '#FF4D4F' : Color.Transparent)
        }
        .onClick(() => { this.onChange?.(index); })
      }, (tab: TabItem, index: number) => tab.label + '_' + index)
    }
    .width('100%')
    .height(36)
    .padding({ left: 4, right: 4 })
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceAround)
  }
}

@Component
struct OrderCard {
  @Prop order: Order = new OrderTemp();
  onCancel?: VoidCallback;
  onConfirm?: VoidCallback;
  onDetail?: VoidCallback;

  getStatusText(): string {
    if (this.order.status === OrderStatus.PENDING_PAYMENT) { return '待付款'; }
    if (this.order.status === OrderStatus.PENDING_SHIPMENT) { return '待发货'; }
    if (this.order.status === OrderStatus.PENDING_RECEIPT) { return '待收货'; }
    if (this.order.status === OrderStatus.COMPLETED) { return '已完成'; }
    if (this.order.status === OrderStatus.CANCELLED) { return '已取消'; }
    return '未知';
  }

  getStatusColor(): string {
    if (this.order.status === OrderStatus.PENDING_PAYMENT) { return '#FF4D4F'; }
    if (this.order.status === OrderStatus.PENDING_SHIPMENT) { return '#FAAD14'; }
    if (this.order.status === OrderStatus.PENDING_RECEIPT) { return '#1890FF'; }
    if (this.order.status === OrderStatus.COMPLETED) { return '#52C41A'; }
    if (this.order.status === OrderStatus.CANCELLED) { return '#999'; }
    return '#999';
  }

  build() {
    Column() {
      Row() {
        Text(`订单号: ${this.order.orderNo}`)
          .fontSize(13)
          .fontColor('#666')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        Text(this.getStatusText())
          .fontSize(13)
          .fontColor(this.getStatusColor())
      }
      .width('100%')
      .height(36)
      .alignItems(VerticalAlign.Center)

      Divider().color('#F0F0F0').strokeWidth(1)

      if (this.order.items && this.order.items.length > 0) {
        ForEach(this.order.items.slice(0, 3), (item: OrderItem) => {
          Row() {
            Image(item.productImage || '')
              .width(88)
              .height(88)
              .objectFit(ImageFit.Cover)
              .borderRadius(8)
              .alt($r('app.media.app_icon'))

            Column() {
              Text(item.productName)
                .fontSize(14)
                .fontColor('#333')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')

              Blank()
                .layoutWeight(1)

              Row() {
                Text(`¥${item.price}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF4D4F')

                Text(`x${item.quantity}`)
                  .fontSize(13)
                  .fontColor('#999')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Center)
              .margin({ top: 6 })
            }
            .layoutWeight(1)
            .height(88)
            .margin({ left: 10 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }, (item: OrderItem) => item.itemId)
      }

      if (this.order.items && this.order.items.length > 3) {
        Text(`等 ${this.order.items.length} 件商品`)
          .fontSize(12)
          .fontColor('#999')
          .width('100%')
          .textAlign(TextAlign.End)
          .margin({ top: 4, bottom: 4 })
      }

      Divider().color('#F0F0F0').strokeWidth(1)

      Row() {
        Text(`共 ${this.order.items ? this.order.items.length : 0} 件商品`)
          .fontSize(13)
          .fontColor('#666')

        Text(' 合计: ')
          .fontSize(13)
          .fontColor('#666')
        Text(`¥${this.order.totalAmount}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF4D4F')
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)

      if (this.order.status === OrderStatus.PENDING_PAYMENT) {
        Row() {
          Button('取消订单')
            .fontSize(13)
            .fontColor('#666')
            .backgroundColor('#F5F5F5')
            .borderRadius(16)
            .height(32)
            .width(88)
            .margin({ right: 10 })
            .onClick(() => { this.onCancel?.(); })

          Button('立即付款')
            .fontSize(13)
            .fontColor(Color.White)
            .backgroundColor('#FF4D4F')
            .borderRadius(16)
            .height(32)
            .width(88)
            .onClick(() => { this.onDetail?.(); })
        }
        .width('100%')
        .height(44)
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)
      } else if (this.order.status === OrderStatus.PENDING_RECEIPT) {
        Row() {
          Button('确认收货')
            .fontSize(13)
            .fontColor(Color.White)
            .backgroundColor('#FF4D4F')
            .borderRadius(16)
            .height(32)
            .width(88)
            .onClick(() => { this.onConfirm?.(); })
        }
        .width('100%')
        .height(44)
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ bottom: 10 })
    .onClick(() => { this.onDetail?.(); })
  }
}

class OrderTemp {
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
  expireTime: number = 0;
}
