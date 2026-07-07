import { OrderService } from '../services/order/OrderService';
import { Order, OrderItem, OrderStatus } from '../common/models';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { RouteConstants } from '../common/constants/RouteConstants';
import { PayPageParams } from '../common/models/PaymentTypes';
import { OrderRefreshUtil } from '../common/utils/OrderRefreshUtil';

interface OrderDetailPageParams {
  orderId: string;
}

function getStatusText(status: OrderStatus): string {
  if (status === OrderStatus.PENDING_PAYMENT) return '待付款';
  if (status === OrderStatus.PENDING_SHIPMENT) return '待发货';
  if (status === OrderStatus.PENDING_RECEIPT) return '待收货';
  if (status === OrderStatus.COMPLETED) return '已完成';
  if (status === OrderStatus.CANCELLED) return '已取消';
  if (status === OrderStatus.EXPIRED) return '已超时';
  return '未知';
}

function getStatusColor(status: OrderStatus): string {
  if (status === OrderStatus.PENDING_PAYMENT) return '#FF4D4F';
  if (status === OrderStatus.PENDING_SHIPMENT) return '#FAAD14';
  if (status === OrderStatus.PENDING_RECEIPT) return '#1890FF';
  if (status === OrderStatus.COMPLETED) return '#52C41A';
  if (status === OrderStatus.CANCELLED) return '#999';
  if (status === OrderStatus.EXPIRED) return '#999';
  return '#999';
}

function formatTime(timestamp: number): string {
  if (!timestamp || timestamp <= 0) return '';
  return new Date(timestamp).toLocaleString();
}

@Entry
@Component
struct OrderDetailPage {
  @State order: Order | null = null;
  @State isLoading: boolean = true;
  @State timerTick: number = 0;
  @StorageLink(OrderRefreshUtil.getKey()) @Watch('onRefreshTriggered') refreshTrigger: number = 0;
  private orderId: string = '';
  private timerId: number = -1;

  onRefreshTriggered(): void {
    if (this.orderId.length > 0) {
      this.silentReload();
    }
  }

  onPageShow(): void {
    if (this.orderId.length > 0) {
      this.silentReload();
    }
    this.startTimer();
  }

  onPageHide(): void {
    this.stopTimer();
  }

  aboutToAppear(): void {
    const params: Object = router.getParams();
    if (params !== undefined) {
      const pageParams = params as OrderDetailPageParams;
      this.orderId = pageParams.orderId;
      this.loadDetail();
    }
    this.startTimer();
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

  async silentReload(): Promise<void> {
    try {
      const service: OrderService = OrderService.getInstance();
      const result: Order | null = await service.getOrderDetail(this.orderId);
      if (result) {
        this.order = result;
      }
    } catch (e) {
    }
  }

  async loadDetail(): Promise<void> {
    this.isLoading = true;
    try {
      const service: OrderService = OrderService.getInstance();
      const result: Order | null = await service.getOrderDetail(this.orderId);
      this.order = result;
    } catch (e) {
      this.order = null;
    }
    this.isLoading = false;
  }

  async cancelOrder(): Promise<void> {
    if (!this.order) return;
    const service: OrderService = OrderService.getInstance();
    const success: boolean = await service.cancelOrder(this.order.orderId);
    if (success) {
      OrderRefreshUtil.trigger();
      promptAction.showToast({ message: '订单已取消' });
      this.loadDetail();
    } else {
      promptAction.showToast({ message: '取消失败，请重试' });
    }
  }

  async confirmReceipt(): Promise<void> {
    if (!this.order) return;
    const service: OrderService = OrderService.getInstance();
    const success: boolean = await service.confirmReceipt(this.order.orderId);
    if (success) {
      OrderRefreshUtil.trigger();
      promptAction.showToast({ message: '确认收货成功' });
      this.loadDetail();
    } else {
      promptAction.showToast({ message: '操作失败，请重试' });
    }
  }

  goToPayment(): void {
    if (!this.order) return;
    const payParams: PayPageParams = {
      orderId: this.order.orderId,
      orderNo: this.order.orderNo,
      amount: this.order.totalAmount
    };
    router.pushUrl({
      url: RouteConstants.PAYMENT,
      params: payParams
    });
  }

  goToReview(): void {
    if (!this.order) return;
    promptAction.showToast({ message: '评价功能开发中，感谢您的耐心等待' });
    // TODO: 跳转到评价页面
  }

  async deleteOrder(): Promise<void> {
    if (!this.order) return;
    const service: OrderService = OrderService.getInstance();
    const success: boolean = await service.deleteOrder(this.order.orderId);
    if (success) {
      OrderRefreshUtil.trigger();
      promptAction.showToast({ message: '订单已删除' });
      router.back();
    } else {
      promptAction.showToast({ message: '操作失败，请重试' });
    }
  }

  async shipOrder(): Promise<void> {
    if (!this.order) return;
    const service: OrderService = OrderService.getInstance();
    const success: boolean = await service.shipOrder(this.order.orderId);
    if (success) {
      OrderRefreshUtil.trigger();
      promptAction.showToast({ message: '已发货' });
      this.loadDetail();
    } else {
      promptAction.showToast({ message: '操作失败，请重试' });
    }
  }

  @Builder
  NavBar() {
    Row() {
      Text('‹')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .onClick(() => router.back())

      Text('订单详情')
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
  StatusCard() {
    Column() {
      Row() {
        Text('订单状态')
          .fontSize(14)
          .fontColor('#666')
        Text(getStatusText(this.order!.status))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(getStatusColor(this.order!.status))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Text(`订单号：${this.order!.orderNo}`)
        .fontSize(13)
        .fontColor('#999')
        .margin({ top: 10 })
        .width('100%')

      Text(`下单时间：${formatTime(this.order!.createdAt)}`)
        .fontSize(13)
        .fontColor('#999')
        .margin({ top: 4 })
        .width('100%')

      if (this.order!.status === OrderStatus.PENDING_PAYMENT && this.order!.expireTime > 0) {
        Text(`支付截止：${formatTime(this.order!.expireTime)}`)
          .fontSize(13)
          .fontColor('#FF4D4F')
          .margin({ top: 4 })
          .width('100%')
        Text('⏳ 剩余时间：' + this.formatCountdown(this.order!.expireTime, this.timerTick))
          .fontSize(14)
          .fontColor('#FF9500')
          .fontWeight(FontWeight.Medium)
          .margin({ top: 4 })
          .width('100%')
      }

      if (this.order!.status !== OrderStatus.PENDING_PAYMENT && this.order!.paidAt && this.order!.paidAt > 0) {
        Text(`支付时间：${formatTime(this.order!.paidAt)}`)
          .fontSize(13)
          .fontColor('#52C41A')
          .margin({ top: 4 })
          .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ bottom: 10 })
  }

  @Builder
  AddressCard() {
    Column() {
      Row() {
        Text('收货地址')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
      }
      .width('100%')
      .margin({ bottom: 10 })

      if (this.order!.address && this.order!.address.length > 0) {
        Text(this.order!.address)
          .fontSize(13)
          .fontColor('#666')
          .width('100%')
          .lineHeight(20)
      } else {
        Text('暂无地址信息')
          .fontSize(13)
          .fontColor('#999')
          .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ bottom: 10 })
  }

  @Builder
  LogisticsCard() {
    Column() {
      Row() {
        Text('物流状态')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
        Text(this.order!.status === OrderStatus.PENDING_SHIPMENT ? '待发货'
          : this.order!.status === OrderStatus.PENDING_RECEIPT ? '运输中'
            : this.order!.status === OrderStatus.COMPLETED ? '已签收'
              : '-')
          .fontSize(13)
          .fontColor('#666')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 8 })

      Text('物流信息将在商家发货后更新')
        .fontSize(13)
        .fontColor('#999')
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ bottom: 10 })
  }

  @Builder
  ProductCard() {
    Column() {
      Text('商品信息')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
        .margin({ bottom: 12 })
        .width('100%')

      ForEach(this.order!.items, (item: OrderItem, index: number) => {
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
      }, (item: OrderItem, index: number) => item.itemId + '_' + index)

      Divider().color('#EEE').margin({ top: 8, bottom: 8 })

      Row() {
        Text('商品总价')
          .fontSize(13)
          .fontColor('#666')
        Text(`¥${this.order!.totalAmount.toFixed(2)}`)
          .fontSize(13)
          .fontColor('#333')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 6 })

      Row() {
        Text('运费')
          .fontSize(13)
          .fontColor('#666')
        Text('免运费')
          .fontSize(13)
          .fontColor('#333')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 6 })

      Row() {
        Text('合计')
          .fontSize(14)
          .fontColor('#333')
          .layoutWeight(1)
        Text(`¥${this.order!.totalAmount.toFixed(2)}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF4D4F')
      }
      .width('100%')
      .padding({ top: 4, bottom: 4 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ bottom: 10 })
  }

  @Builder
  PaymentCard() {
    Column() {
      Row() {
        Text('支付信息')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
        Text(this.order!.status !== OrderStatus.PENDING_PAYMENT &&
          this.order!.status !== OrderStatus.CANCELLED &&
          this.order!.status !== OrderStatus.EXPIRED ? '已支付' : '未支付')
          .fontSize(13)
          .fontColor(this.order!.status !== OrderStatus.PENDING_PAYMENT &&
            this.order!.status !== OrderStatus.CANCELLED &&
            this.order!.status !== OrderStatus.EXPIRED ? '#52C41A' : '#FF4D4F')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 8 })

      if (this.order!.status !== OrderStatus.PENDING_PAYMENT &&
        this.order!.status !== OrderStatus.CANCELLED &&
        this.order!.status !== OrderStatus.EXPIRED) {
        Text(`支付金额：¥${this.order!.totalAmount.toFixed(2)}`)
          .fontSize(13)
          .fontColor('#666')
          .width('100%')
          .margin({ bottom: 4 })

        if (this.order!.paidAt && this.order!.paidAt > 0) {
          Text(`支付时间：${formatTime(this.order!.paidAt)}`)
            .fontSize(13)
            .fontColor('#666')
            .width('100%')
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ bottom: 10 })
  }

  @Builder
  RemarkCard() {
    Column() {
      Text('订单备注')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
        .margin({ bottom: 8 })
        .width('100%')

      Text(this.order!.remark && this.order!.remark.length > 0 ? this.order!.remark : '无备注')
        .fontSize(13)
        .fontColor('#666')
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ bottom: 10 })
  }

  build() {
    Column() {
      this.NavBar()

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(36).height(36).color('#FF4D4F')
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else if (!this.order) {
        Column() {
          Text('订单不存在').fontSize(16).fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else {
        Scroll() {
          Column() {
            this.StatusCard()
            this.AddressCard()
            this.LogisticsCard()
            this.ProductCard()
            this.PaymentCard()
            this.RemarkCard()
          }
          .padding({ left: 12, right: 12, top: 12, bottom: 80 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#F5F5F5')

        if (this.order.status === OrderStatus.PENDING_PAYMENT ||
            this.order.status === OrderStatus.PENDING_SHIPMENT ||
            this.order.status === OrderStatus.PENDING_RECEIPT ||
            this.order.status === OrderStatus.COMPLETED ||
            this.order.status === OrderStatus.CANCELLED ||
            this.order.status === OrderStatus.EXPIRED) {
          Row() {
            if (this.order.status === OrderStatus.PENDING_PAYMENT) {
              Button('取消订单')
                .fontSize(14)
                .fontColor('#666')
                .backgroundColor('#F5F5F5')
                .borderRadius(22)
                .height(40)
                .width(120)
                .margin({ right: 12 })
                .onClick(() => this.cancelOrder())
            }

            if (this.order.status === OrderStatus.PENDING_SHIPMENT) {
              Button('模拟发货')
                .fontSize(14)
                .fontColor('#666')
                .backgroundColor('#F5F5F5')
                .borderRadius(22)
                .height(40)
                .width(120)
                .margin({ right: 12 })
                .onClick(() => this.shipOrder())
            }

            if (this.order.status !== OrderStatus.PENDING_PAYMENT &&
              this.order.status !== OrderStatus.PENDING_SHIPMENT) {
              Button('删除订单')
                .fontSize(14)
                .fontColor('#999')
                .backgroundColor('#F5F5F5')
                .borderRadius(22)
                .height(40)
                .width(120)
                .margin({ right: 12 })
                .onClick(() => this.deleteOrder())
            }

            if (this.order.status !== OrderStatus.PENDING_SHIPMENT) {
              Button(this.order.status === OrderStatus.PENDING_PAYMENT ? '立即付款' :
                (this.order.status === OrderStatus.COMPLETED ? '去评价' : '确认收货'))
                .fontSize(14)
                .backgroundColor('#FF4D4F')
                .fontColor(Color.White)
                .borderRadius(22)
                .height(40)
                .width(160)
                .onClick(() => {
                  if (this.order!.status === OrderStatus.PENDING_PAYMENT) {
                    this.goToPayment();
                  } else if (this.order!.status === OrderStatus.COMPLETED) {
                    this.goToReview();
                  } else if (this.order!.status === OrderStatus.PENDING_RECEIPT) {
                    this.confirmReceipt();
                  }
                })
            }
          }
          .width('100%')
          .height(64)
          .justifyContent(FlexAlign.End)
          .padding({ right: 16 })
          .backgroundColor(Color.White)
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
