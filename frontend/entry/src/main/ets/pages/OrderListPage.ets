import { OrderService } from '../services/order/OrderService';
import { Order, OrderStatus } from '../common/models';
import router from '@ohos.router';

@Entry
@Component
struct OrderListPage {
  @State orders: Order[] = [];
  @State isLoading: boolean = true;
  @State activeTab: number = 0;

  aboutToAppear(): void {
    this.loadOrders();
  }

  async loadOrders(): Promise<void> {
    this.isLoading = true;
    try {
      const service: OrderService = OrderService.getInstance();
      const allOrders: Order[] = await service.getAllOrders('default_user');
      this.orders = allOrders;
    } catch (e) {
      this.orders = [];
    }
    this.isLoading = false;
  }

  getFilteredOrders(): Order[] {
    if (this.activeTab === 0) {
      return this.orders;
    }
    return this.orders.filter((o: Order) => o.status === (this.activeTab as OrderStatus));
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
    if (status === OrderStatus.CANCELLED) { return '#999'; }
    return '#52C41A';
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
          .fontColor(this.activeTab === 0 ? '#FF4D4F' : '#333')
          .padding(8)
          .onClick(() => { this.activeTab = 0; })

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
