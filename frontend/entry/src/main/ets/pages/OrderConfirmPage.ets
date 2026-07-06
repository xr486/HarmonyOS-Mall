import { CartService } from '../services/cart/CartService';
import { AddressService } from '../services/user/AddressService';
import { OrderService } from '../services/order/OrderService';
import { CartItem, Address, Order } from '../common/models';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Logger } from '../common/utils/logger/Logger';
import { OrderRefreshUtil } from '../common/utils/OrderRefreshUtil';

const TAG = 'OrderConfirmPage';

@Entry
@Component
struct OrderConfirmPage {
  @State cartItems: CartItem[] = [];
  @State addresses: Address[] = [];
  @State selectedAddressId: string = '';
  @State remark: string = '';
  @State isLoading: boolean = true;
  @State submitting: boolean = false;
  private cartIds: string[] = [];

  aboutToAppear(): void {
    const params: Record<string, Object> = router.getParams() as Record<string, Object>;
    if (params && params['cartIds']) {
      const ids: string[] = params['cartIds'] as string[];
      this.cartIds = ids;
    }
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    await this.loadCartItems();
    await this.loadAddresses();
    this.isLoading = false;
  }

  async loadCartItems(): Promise<void> {
    try {
      const service: CartService = CartService.getInstance();
      const items: CartItem[] = await service.getCartItems('default_user');
      const selected: CartItem[] = [];
      for (let i: number = 0; i < items.length; i++) {
        const item: CartItem = items[i];
        if (this.cartIds.length > 0) {
          // 只展示传入的购物车项
          if (this.cartIds.indexOf(item.cartId) >= 0) {
            selected.push(item);
          }
        } else if (item.selected) {
          selected.push(item);
        }
      }
      this.cartItems = selected;
    } catch (e) {
      Logger.error(TAG, 'loadCartItems error: %{public}s', JSON.stringify(e));
      this.cartItems = [];
    }
  }

  async loadAddresses(): Promise<void> {
    try {
      const service: AddressService = AddressService.getInstance();
      const list: Address[] = await service.getAddressesByUserId('default_user');
      this.addresses = list;
      // 优先选中默认地址
      for (let i: number = 0; i < list.length; i++) {
        if (list[i].isDefault) {
          this.selectedAddressId = list[i].addressId;
          break;
        }
      }
      // 没有默认地址则选中第一个
      if (this.selectedAddressId === '' && list.length > 0) {
        this.selectedAddressId = list[0].addressId;
      }
    } catch (e) {
      Logger.error(TAG, 'loadAddresses error: %{public}s', JSON.stringify(e));
      this.addresses = [];
    }
  }

  getSelectedAddress(): Address | null {
    for (let i: number = 0; i < this.addresses.length; i++) {
      if (this.addresses[i].addressId === this.selectedAddressId) {
        return this.addresses[i];
      }
    }
    return null;
  }

  getAddressName(): string {
    const a: Address | null = this.getSelectedAddress();
    return a ? a.name : '';
  }

  getAddressPhone(): string {
    const a: Address | null = this.getSelectedAddress();
    return a ? a.phone : '';
  }

  getAddressFull(): string {
    const a: Address | null = this.getSelectedAddress();
    if (!a) {
      return '';
    }
    return a.province + a.city + a.district + a.detail;
  }

  getTotalPrice(): number {
    let total: number = 0;
    for (let i: number = 0; i < this.cartItems.length; i++) {
      total += this.cartItems[i].price * this.cartItems[i].quantity;
    }
    return total;
  }

  getItemCount(): number {
    let count: number = 0;
    for (let i: number = 0; i < this.cartItems.length; i++) {
      count += this.cartItems[i].quantity;
    }
    return count;
  }

  getCartIds(): string[] {
    const ids: string[] = [];
    for (let i: number = 0; i < this.cartItems.length; i++) {
      ids.push(this.cartItems[i].cartId);
    }
    return ids;
  }

  goToAddressList(): void {
    router.pushUrl({
      url: 'pages/AddressList',
      params: { fromOrder: true }
    });
  }

  async submitOrder(): Promise<void> {
    if (this.cartItems.length === 0) {
      promptAction.showToast({ message: '请选择要结算的商品' });
      return;
    }
    if (this.selectedAddressId === '') {
      promptAction.showToast({ message: '请选择收货地址' });
      return;
    }

    this.submitting = true;
    try {
      const service: OrderService = OrderService.getInstance();
      const order: Order | null = await service.createOrder(
        this.getCartIds(),
        this.selectedAddressId,
        this.remark
      );
      if (order && order.orderId) {
        OrderRefreshUtil.trigger();
        promptAction.showToast({ message: '下单成功' });
        router.replaceUrl({
          url: 'pages/OrderDetailPage',
          params: { orderId: order.orderId }
        });
      } else {
        promptAction.showToast({ message: '下单失败，请重试' });
      }
    } catch (e) {
      promptAction.showToast({ message: '网络异常，请重试' });
    }
    this.submitting = false;
  }

  @Builder
  NavBar() {
    Row() {
      Text('‹')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .onClick(() => router.back())

      Text('确认订单')
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
  AddressSection() {
    Column() {
      if (this.addresses.length === 0) {
        Row() {
          Text('暂无收货地址，去添加')
            .fontSize(14)
            .fontColor('#FF4D4F')
          Text('›')
            .fontSize(18)
            .fontColor('#999')
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .onClick(() => this.goToAddressList())
      } else {
        Row() {
          Column() {
            Row() {
              Text(this.getAddressName())
                .fontSize(15)
                .fontColor('#333')
                .fontWeight(FontWeight.Medium)
              Text(this.getAddressPhone())
                .fontSize(14)
                .fontColor('#666')
                .margin({ left: 12 })
            }
            .width('100%')
            .margin({ bottom: 6 })

            Text(this.getAddressFull())
              .fontSize(13)
              .fontColor('#666')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Text('›')
            .fontSize(18)
            .fontColor('#999')
            .margin({ left: 8 })
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })
        .alignItems(VerticalAlign.Center)
        .onClick(() => this.goToAddressList())
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ left: 12, right: 12, top: 12, bottom: 8 })
  }

  @Builder
  ProductCard(item: CartItem) {
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

        if (item.specs && item.specs.length > 0) {
          Text(item.specs)
            .fontSize(12)
            .fontColor('#999')
            .margin({ top: 4 })
            .width('100%')
        }

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
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ bottom: 10 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  RemarkSection() {
    Row() {
      Text('订单备注')
        .fontSize(14)
        .fontColor('#333')
        .width(72)

      TextInput({ text: this.remark, placeholder: '请输入备注信息（选填）' })
        .fontSize(14)
        .fontColor('#333')
        .placeholderColor('#999')
        .backgroundColor(Color.Transparent)
        .layoutWeight(1)
        .onChange((value: string) => { this.remark = value; })
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ left: 12, right: 12, bottom: 8 })
    .alignItems(VerticalAlign.Center)
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
      } else if (this.cartItems.length === 0) {
        Column() {
          Text('没有可结算的商品').fontSize(16).fontColor('#999')
          Button('返回购物车')
            .fontSize(14)
            .backgroundColor('#FF4D4F')
            .borderRadius(20)
            .height(36)
            .margin({ top: 16 })
            .onClick(() => router.back())
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#F5F5F5')
      } else {
        Scroll() {
          Column() {
            this.AddressSection()

            Column() {
              ForEach(this.cartItems, (item: CartItem, index: number) => {
                this.ProductCard(item)
              }, (item: CartItem, index: number) => item.cartId + '_' + index)
            }
            .padding({ left: 12, right: 12 })
            .width('100%')

            this.RemarkSection()
          }
          .padding({ bottom: 12 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#F5F5F5')

        Column() {
          Divider().color('#EEE').strokeWidth(1)

          Row() {
            Text(`共 ${this.getItemCount()} 件`)
              .fontSize(14)
              .fontColor('#333')
              .layoutWeight(1)

            Text('合计: ')
              .fontSize(14)
              .fontColor('#333')
            Text(`¥${this.getTotalPrice()}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF4D4F')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .alignItems(VerticalAlign.Center)

          Button(this.submitting ? '提交中...' : `提交订单(${this.getItemCount()})`)
            .fontSize(16)
            .backgroundColor('#FF4D4F')
            .fontColor(Color.White)
            .borderRadius(24)
            .height(44)
            .width('92%')
            .enabled(!this.submitting)
            .onClick(() => this.submitOrder())
        }
        .width('100%')
        .backgroundColor(Color.White)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
