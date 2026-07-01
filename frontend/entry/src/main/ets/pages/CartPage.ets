import { CartService } from '../services/cart/CartService';
import { CartItem } from '../common/models';
import router from '@ohos.router';

@Entry
@Component
struct CartPage {
  @State cartItems: CartItem[] = [];
  @State isLoading: boolean = true;
  @State allSelected: boolean = true;

  aboutToAppear(): void {
    this.loadCart();
  }

  async loadCart(): Promise<void> {
    this.isLoading = true;
    try {
      const service: CartService = CartService.getInstance();
      const items: CartItem[] = await service.getCartItems('default_user');
      this.cartItems = items;
      this.updateAllSelected();
    } catch (e) {
      this.cartItems = [];
    }
    this.isLoading = false;
  }

  updateAllSelected(): void {
    if (this.cartItems.length === 0) {
      this.allSelected = false;
      return;
    }
    const unselected: CartItem | undefined = this.cartItems.find((item: CartItem) => !item.selected);
    this.allSelected = unselected === undefined;
  }

  toggleAllSelected(): void {
    this.allSelected = !this.allSelected;
    const newItems: CartItem[] = [];
    for (let i: number = 0; i < this.cartItems.length; i++) {
      const item: CartItem = this.cartItems[i];
      const newItem: CartItem = {
        cartId: item.cartId,
        userId: item.userId,
        productId: item.productId,
        productName: item.productName,
        productImage: item.productImage,
        price: item.price,
        quantity: item.quantity,
        selected: this.allSelected,
        stock: item.stock,
        addedAt: item.addedAt
      };
      newItems.push(newItem);
    }
    this.cartItems = newItems;
  }

  async toggleItem(cartId: string): Promise<void> {
    const newItems: CartItem[] = [];
    for (let i: number = 0; i < this.cartItems.length; i++) {
      const item: CartItem = this.cartItems[i];
      const isSelected: boolean = item.cartId === cartId ? !item.selected : item.selected;
      const newItem: CartItem = {
        cartId: item.cartId,
        userId: item.userId,
        productId: item.productId,
        productName: item.productName,
        productImage: item.productImage,
        price: item.price,
        quantity: item.quantity,
        selected: isSelected,
        stock: item.stock,
        addedAt: item.addedAt
      };
      newItems.push(newItem);
    }
    this.cartItems = newItems;
    this.updateAllSelected();
  }

  getTotalPrice(): number {
    let total: number = 0;
    for (let i: number = 0; i < this.cartItems.length; i++) {
      if (this.cartItems[i].selected) {
        total += this.cartItems[i].price * this.cartItems[i].quantity;
      }
    }
    return total;
  }

  getSelectedCount(): number {
    let count: number = 0;
    for (let i: number = 0; i < this.cartItems.length; i++) {
      if (this.cartItems[i].selected) {
        count++;
      }
    }
    return count;
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(22)
          .onClick(() => { router.back(); })
        Text('购物车')
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

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40)
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.cartItems.length === 0) {
        Column() {
          Text('购物车是空的')
            .fontSize(16)
            .fontColor('#999')
          Text('快去逛逛吧')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.cartItems, (item: CartItem) => {
              Row() {
                Checkbox({ name: item.cartId, group: 'cart' })
                  .select(item.selected)
                  .onChange((value: boolean) => { this.toggleItem(item.cartId); })

                if (item.productImage) {
                  Image(item.productImage)
                    .width(80)
                    .height(80)
                    .borderRadius(6)
                    .alt($r('app.media.app_icon'))
                } else {
                  Column()
                    .width(80)
                    .height(80)
                    .borderRadius(6)
                    .backgroundColor('#F0F0F0')
                }

                Column() {
                  Text(item.productName)
                    .fontSize(14)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

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
                  .margin({ top: 8 })
                  .justifyContent(FlexAlign.SpaceBetween)
                }
                .layoutWeight(1)
                .margin({ left: 10 })
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .margin({ bottom: 8 })
            }, (item: CartItem) => item.cartId)
          }
          .padding(12)
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#F5F5F5')

        Row() {
          Checkbox({ name: 'all', group: 'cart' })
            .select(this.allSelected)
            .onChange((value: boolean) => { this.toggleAllSelected(); })

          Text('全选')
            .fontSize(14)

          Text(`合计: ¥${this.getTotalPrice()}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF4D4F')
            .layoutWeight(1)
            .textAlign(TextAlign.End)

          Button(`结算(${this.getSelectedCount()})`)
            .fontSize(14)
            .backgroundColor('#FF4D4F')
            .borderRadius(20)
            .height(36)
            .onClick(() => {
              router.pushUrl({ url: 'pages/OrderListPage' });
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
      }
    }
    .width('100%')
    .height('100%')
  }
}
