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
  @State searchKeyword: string = '';
  @State timerTick: number = 0;
  @StorageLink(OrderRefreshUtil.getKey()) @Watch('onRefreshTriggered') refreshTrigger: number = 0;
  private timerId: number = -1;

  private tabs: TabItem[] = [
    { label: '全部', status: 0 },
    { label: '待付款', status: OrderStatus.PENDING_PAYMENT },
    { label: '待发货', status: OrderStatus.PENDING_SHIPMENT },
    { label: '待收货', status: OrderStatus.PENDING_RECEIPT },
    { label: '已完成', status: OrderStatus.COMPLETED },
    { label: '已取消', status: OrderStatus.CANCELLED },
    { label: '已超时', status: OrderStatus.EXPIRED }
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
    this.startTimer();
  }

  onPageShow(): void {
    this.loadOrders();
    this.startTimer();
  }

  onPageHide(): void {
    this.stopTimer();
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  startTimer(): void {
    this.stopTimer();
    this.timerId = setInterval(() => {
      this.timerTick++;
    }, 1000);
  }

  stopTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  onRefreshTriggered(): void {
    this.loadOrders();
  }

  async loadOrders(): Promise<void> {
    this.isLoading = true;
    try {
      const service: OrderService = OrderService.getInstance();
      const status: number = this.tabs[this.activeTab].status;
      const keyword: string = this.searchKeyword.trim().length > 0 ? this.searchKeyword : '';
      const allOrders: Order[] = await service.getAllOrders('default_user',
        status === 0 ? undefined : status,
        keyword.length > 0 ? keyword : undefined);
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
    if (status === OrderStatus.EXPIRED) { return '已超时'; }
    return '未知';
  }

  getStatusColor(status: OrderStatus): string {
    if (status === OrderStatus.PENDING_PAYMENT) { return '#FF4D4F'; }
    if (status === OrderStatus.PENDING_SHIPMENT) { return '#FAAD14'; }
    if (status === OrderStatus.PENDING_RECEIPT) { return '#1890FF'; }
    if (status === OrderStatus.COMPLETED) { return '#52C41A'; }
    if (status === OrderStatus.CANCELLED) { return '#999999'; }
    if (status === OrderStatus.EXPIRED) { return '#999999'; }
    return '#999999';
  }

  formatCountdown(expireTime: number, tick: number): string {
    const now: number = Date.now();
    const remain: number = expireTime - now;
    if (remain <= 0) return '已超时';
    const min: number = Math.floor(remain / 60000);
    const sec: number = Math.floor((remain % 60000) / 1000);
    const mm: string = min < 10 ? '0' + min : String(min);
    const ss: string = sec < 10 ? '0' + sec : String(sec);
    return mm + ':' + ss + ' 后失效';
  }

  async deleteOrder(order: Order, index: number): Promise<void> {
    this.orders.splice(index, 1);
    promptAction.showToast({ message: '订单已删除' });

    try {
      const service: OrderService = OrderService.getInstance();
      await service.deleteOrder(order.orderId);
    } catch (e) {
    }
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
  SearchBar() {
    Row() {
      TextInput({ text: this.searchKeyword, placeholder: '搜索订单号或商品名称' })
        .fontSize(13)
        .backgroundColor('#F5F5F5')
        .borderRadius(16)
        .height(32)
        .layoutWeight(1)
        .onChange((value: string) => {
          this.searchKeyword = value;
        })
        .onSubmit(() => {
          this.loadOrders();
        })
    }
    .width('100%')
    .height(44)
    .padding({ left: 12, right: 12 })
    .backgroundColor(Color.White)
    .border({ width: { bottom: 0.5 }, color: '#EEEEEE' })
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
        Text(`订单号: ${order.orderNo}`)
          .fontSize(13)
          .fontColor('#666')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        Text(this.getStatusText(order.status))
          .fontSize(13)
          .fontColor(this.getStatusColor(order.status))
      }
      .width('100%')
      .height(36)
      .alignItems(VerticalAlign.Center)

      if (order.status === OrderStatus.PENDING_PAYMENT) {
        Text('⏳ ' + this.formatCountdown(order.expireTime, this.timerTick))
          .fontSize(12)
          .fontColor('#FF9500')
          .width('100%')
          .textAlign(TextAlign.End)
          .margin({ bottom: 4 })
      }

      Divider().color('#F0F0F0').strokeWidth(1)

      if (order.items && order.items.length > 0) {
        ForEach(order.items.slice(0, 3), (item: OrderItem) => {
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

      if (order.items && order.items.length > 3) {
        Text(`等 ${order.items.length} 件商品`)
          .fontSize(12)
          .fontColor('#999')
          .width('100%')
          .textAlign(TextAlign.End)
          .margin({ top: 4, bottom: 4 })
      }

      Divider().color('#F0F0F0').strokeWidth(1)

      Row() {
        Text(`共 ${order.items ? order.items.length : 0} 件商品`)
          .fontSize(13)
          .fontColor('#666')

        Text(' 合计: ')
          .fontSize(13)
          .fontColor('#666')
        Text(`¥${order.totalAmount}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF4D4F')
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)

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

        if (order.status === OrderStatus.COMPLETED) {
          Button('评价')
            .fontSize(13)
            .fontColor('#666')
            .backgroundColor('#F5F5F5')
            .borderRadius(16)
            .height(32)
            .padding({ left: 16, right: 16 })
            .margin({ right: 8 })
            .onClick(() => {
              promptAction.showToast({ message: '评价功能开发中，感谢您的耐心等待' });
            })
        }

        if (order.status === OrderStatus.CANCELLED || order.status === OrderStatus.EXPIRED) {
          Button('删除订单')
            .fontSize(13)
            .fontColor('#999')
            .backgroundColor('#F5F5F5')
            .borderRadius(16)
            .height(32)
            .padding({ left: 16, right: 16 })
            .onClick(() => this.deleteOrder(order, index))
        }
      }
      .width('100%')
      .height(44)
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ top: 10 })
    .onClick(() => this.goToDetail(order))
  }

  build() {
    Column() {
      this.NavBar()
      this.SearchBar()
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
          .justifyContent(FlexAlign.Start)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#F5F5F5')
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
