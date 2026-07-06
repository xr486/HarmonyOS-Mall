import { CartService } from '../services/cart/CartService';
import { CartItem } from '../common/models';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Logger } from '../common/utils/logger/Logger';

const CART_TAG = 'CartPage';

/**
 * 深拷贝 CartItem，可选择覆盖 selected / quantity 字段
 * （ArkTS 不支持展开运算符，也不支持内联对象类型声明，需分开传参）
 */
function cloneItem(
  src: CartItem,
  newSelected?: boolean,
  newQuantity?: number
): CartItem {
  const out: CartItem = {
    cartId: src.cartId,
    userId: src.userId,
    productId: src.productId,
    productName: src.productName,
    productImage: src.productImage,
    price: src.price,
    quantity: src.quantity,
    selected: src.selected,
    stock: src.stock,
    addedAt: src.addedAt
  };
  if (newSelected !== undefined) { out.selected = newSelected; }
  if (newQuantity !== undefined) { out.quantity = newQuantity; }
  return out;
}

@Entry
@Component
struct CartPage {
  @State cartItems: CartItem[] = [];
  @State isLoading: boolean = true;
  @State allSelected: boolean = true;
  @State isEditing: boolean = false;

  aboutToAppear(): void {
    this.loadCart();
  }

  async loadCart(): Promise<void> {
    this.isLoading = true;
    try {
      const service: CartService = CartService.getInstance();
      const items: CartItem[] = await service.getCartItems('default_user');
      Logger.info(CART_TAG, 'loadCart got %{public}d items', items.length);
      this.cartItems = items;
      this.updateAllSelected();
    } catch (e) {
      Logger.error(CART_TAG, 'loadCart error: %{public}s', JSON.stringify(e));
      this.cartItems = [];
      promptAction.showToast({ message: '加载购物车失败，请检查网络' });
    }
    this.isLoading = false;
  }

  updateAllSelected(): void {
    if (this.cartItems.length === 0) {
      this.allSelected = false;
      return;
    }
    let all: boolean = true;
    for (let i: number = 0; i < this.cartItems.length; i++) {
      if (!this.cartItems[i].selected) {
        all = false;
        break;
      }
    }
    this.allSelected = all;
  }

  // ===== 选中/取消选中 =====

  async toggleAllSelected(): Promise<void> {
    const newChecked: boolean = !this.allSelected;

    const newItems: CartItem[] = [];
    for (let i: number = 0; i < this.cartItems.length; i++) {
      newItems.push(cloneItem(this.cartItems[i], newChecked));
    }
    this.cartItems = newItems;
    this.allSelected = newChecked;

    const service: CartService = CartService.getInstance();
    const cartIds: string[] = [];
    for (let i: number = 0; i < this.cartItems.length; i++) {
      cartIds.push(this.cartItems[i].cartId);
    }
    const success: boolean = await service.selectAll(cartIds, newChecked);
    if (!success) {
      const rollback: CartItem[] = [];
      for (let i: number = 0; i < this.cartItems.length; i++) {
        rollback.push(cloneItem(this.cartItems[i], !newChecked));
      }
      this.cartItems = rollback;
      this.allSelected = !newChecked;
      promptAction.showToast({ message: '网络异常，请重试' });
    }
  }

  async toggleItem(cartId: string): Promise<void> {
    let target: CartItem | null = null;
    for (let i: number = 0; i < this.cartItems.length; i++) {
      if (this.cartItems[i].cartId === cartId) {
        target = this.cartItems[i];
        break;
      }
    }
    if (!target) return;
    const newChecked: boolean = !target.selected;

    const newItems: CartItem[] = [];
    for (let i: number = 0; i < this.cartItems.length; i++) {
      const it: CartItem = this.cartItems[i];
      if (it.cartId === cartId) {
        newItems.push(cloneItem(it, newChecked));
      } else {
        newItems.push(cloneItem(it));
      }
    }
    this.cartItems = newItems;
    this.updateAllSelected();

    const service: CartService = CartService.getInstance();
    const success: boolean = await service.updateCartItemChecked(cartId, newChecked);
    if (!success) {
      const rollback: CartItem[] = [];
      for (let i: number = 0; i < this.cartItems.length; i++) {
        const it: CartItem = this.cartItems[i];
        if (it.cartId === cartId) {
          rollback.push(cloneItem(it, !newChecked));
        } else {
          rollback.push(cloneItem(it));
        }
      }
      this.cartItems = rollback;
      this.updateAllSelected();
      promptAction.showToast({ message: '网络异常，请重试' });
    }
  }

  // ===== 数量调整 =====

  async changeQuantity(cartId: string, delta: number): Promise<void> {
    let target: CartItem | null = null;
    for (let i: number = 0; i < this.cartItems.length; i++) {
      if (this.cartItems[i].cartId === cartId) {
        target = this.cartItems[i];
        break;
      }
    }
    if (!target) return;

    const newQty: number = target.quantity + delta;
    if (newQty < 1) {
      promptAction.showToast({ message: '数量不能小于1' });
      return;
    }
    const maxStock: number = target.stock ?? 99;
    if (newQty > maxStock) {
      promptAction.showToast({ message: `库存仅剩 ${maxStock} 件` });
      return;
    }

    // 乐观更新
    const newItems: CartItem[] = [];
    for (let i: number = 0; i < this.cartItems.length; i++) {
      const it: CartItem = this.cartItems[i];
      if (it.cartId === cartId) {
        newItems.push(cloneItem(it, undefined, newQty));
      } else {
        newItems.push(cloneItem(it));
      }
    }
    this.cartItems = newItems;

    const service: CartService = CartService.getInstance();
    const success: boolean = await service.updateCartItemQuantity(cartId, newQty);
    if (!success) {
      const rollback: CartItem[] = [];
      for (let i: number = 0; i < this.cartItems.length; i++) {
        const it: CartItem = this.cartItems[i];
        if (it.cartId === cartId) {
          rollback.push(cloneItem(it, undefined, target.quantity));
        } else {
          rollback.push(cloneItem(it));
        }
      }
      this.cartItems = rollback;
      promptAction.showToast({ message: '网络异常，请重试' });
    }
  }

  // ===== 删除 =====

  async deleteItem(cartId: string): Promise<void> {
    const service: CartService = CartService.getInstance();
    const success: boolean = await service.removeFromCart(cartId);
    if (success) {
      const newItems: CartItem[] = [];
      for (let i: number = 0; i < this.cartItems.length; i++) {
        if (this.cartItems[i].cartId !== cartId) {
          newItems.push(cloneItem(this.cartItems[i]));
        }
      }
      this.cartItems = newItems;
      this.updateAllSelected();
      promptAction.showToast({ message: '已删除' });
    } else {
      promptAction.showToast({ message: '删除失败，请重试' });
    }
  }

  async deleteSelected(): Promise<void> {
    const selectedIds: string[] = [];
    for (let i: number = 0; i < this.cartItems.length; i++) {
      if (this.cartItems[i].selected) {
        selectedIds.push(this.cartItems[i].cartId);
      }
    }

    if (selectedIds.length === 0) {
      promptAction.showToast({ message: '请先选择要删除的商品' });
      return;
    }

    const service: CartService = CartService.getInstance();
    let successCount: number = 0;
    for (let i: number = 0; i < selectedIds.length; i++) {
      const ok: boolean = await service.removeFromCart(selectedIds[i]);
      if (ok) successCount++;
    }
    await this.loadCart();
    this.isEditing = false;
    promptAction.showToast({ message: `已删除 ${successCount} 件商品` });
  }

  // ===== 计算方法 =====

  getTotalPrice(): number {
    let total: number = 0;
    for (let i: number = 0; i < this.cartItems.length; i++) {
      if (this.cartItems[i].selected) {
        total += this.cartItems[i].price * this.cartItems[i].quantity;
      }
    }
    return total;
  }

  getSubTotal(item: CartItem): number {
    return item.price * item.quantity;
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

  getSelectedItemCount(): number {
    let count: number = 0;
    for (let i: number = 0; i < this.cartItems.length; i++) {
      if (this.cartItems[i].selected) {
        count += this.cartItems[i].quantity;
      }
    }
    return count;
  }

  // ===== 跳转详情页 =====

  goToDetail(productId: string): void {
    router.pushUrl({
      url: 'pages/ProductDetailPage',
      params: { productId: productId }
    });
  }

  // ========== UI 构建 ==========

  @Builder
  NavBar() {
    Row() {
      Text('‹')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .onClick(() => router.back())

      Text('购物车')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text(this.isEditing ? '完成' : '编辑')
        .fontSize(14)
        .fontColor('#FF4D4F')
        .padding({ left: 8, right: 8 })
        .height(28)
        .onClick(() => { this.isEditing = !this.isEditing; })
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }

  @Builder
  EmptyCart() {
    Column() {
      Column() {
        Text('🛒')
          .fontSize(64)
          .margin({ bottom: 16 })

        Text('购物车是空的')
          .fontSize(16)
          .fontColor('#333')
          .fontWeight(FontWeight.Medium)

        Text('快去挑选心仪的商品吧~')
          .fontSize(13)
          .fontColor('#999')
          .margin({ top: 6 })

        Button('去逛逛')
          .fontSize(14)
          .backgroundColor('#FF4D4F')
          .borderRadius(20)
          .height(38)
          .width(140)
          .margin({ top: 24 })
          .onClick(() => {
            router.replaceUrl({ url: 'pages/Index' });
          })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(36)
        .height(36)
        .color('#FF4D4F')
      Text('加载中...')
        .fontSize(14)
        .fontColor('#999')
        .margin({ top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
  }

  @Builder
  CartItemCard(item: CartItem) {
    Row() {
      // 左侧：选择框
      Checkbox({ name: item.cartId, group: 'cart' })
        .select(item.selected)
        .shape(CheckBoxShape.ROUNDED_SQUARE)
        .selectedColor('#FF4D4F')
        .onClick(() => { this.toggleItem(item.cartId); })
        .margin({ right: 10 })

      // 商品图片（可点击）
      Image(item.productImage || '')
        .width(88)
        .height(88)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
        .alt($r('app.media.app_icon'))
        .onClick(() => this.goToDetail(item.productId))

      // 右侧：商品信息
      Column() {
        // 商品名称
        Text(item.productName)
          .fontSize(14)
          .fontColor('#333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .onClick(() => this.goToDetail(item.productId))

        // 规格
        if (item.specs && item.specs.length > 0) {
          Text(item.specs)
            .fontSize(12)
            .fontColor('#999')
            .margin({ top: 4 })
            .width('100%')
        }

        Blank()
          .layoutWeight(1)

        // 价格行 + 数量调整器
        Row() {
          Text(`¥${item.price}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF4D4F')

          // 编辑模式：删除按钮
          if (this.isEditing) {
            Text('删除')
              .fontSize(12)
              .fontColor('#FF4D4F')
              .padding({ left: 12, right: 12, top: 5, bottom: 5 })
              .border({ width: 1, color: '#FF4D4F', radius: 14 })
              .onClick(() => this.deleteItem(item.cartId))
          } else {
            // 数量调整器
            Row() {
              Text('-')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(item.quantity <= 1 ? '#CCC' : '#666')
                .width(26)
                .height(26)
                .textAlign(TextAlign.Center)
                .border({
                  width: { left: 1, top: 1, bottom: 1 },
                  color: '#E0E0E0',
                  radius: { topLeft: 4, bottomLeft: 4 }
                })
                .backgroundColor('#FAFAFA')
                .onClick(() => this.changeQuantity(item.cartId, -1))

              Text(`${item.quantity}`)
                .fontSize(13)
                .fontColor('#333')
                .width(32)
                .height(26)
                .textAlign(TextAlign.Center)
                .border({ width: { top: 1, bottom: 1 }, color: '#E0E0E0' })
                .backgroundColor('#FAFAFA')

              Text('+')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#666')
                .width(26)
                .height(26)
                .textAlign(TextAlign.Center)
                .border({
                  width: { right: 1, top: 1, bottom: 1 },
                  color: '#E0E0E0',
                  radius: { topRight: 4, bottomRight: 4 }
                })
                .backgroundColor('#FAFAFA')
                .onClick(() => this.changeQuantity(item.cartId, 1))
            }
          }
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
  BottomBar() {
    Column() {
      Divider().color('#EEE').strokeWidth(1)

      Row() {
        // 全选
        Row() {
          Checkbox({ name: 'all', group: 'cart' })
            .select(this.allSelected)
            .shape(CheckBoxShape.ROUNDED_SQUARE)
            .selectedColor('#FF4D4F')
            .onClick(() => { this.toggleAllSelected(); })
          Text('全选')
            .fontSize(14)
            .fontColor('#333')
            .margin({ left: 6 })
        }
        .onClick(() => this.toggleAllSelected())
        .height(44)
        .alignItems(VerticalAlign.Center)

        Blank()

        if (this.isEditing) {
          // 编辑模式：删除按钮
          Button(`删除(${this.getSelectedCount()})`)
            .fontSize(14)
            .backgroundColor(this.getSelectedCount() > 0 ? '#FF4D4F' : '#CCC')
            .fontColor(Color.White)
            .borderRadius(18)
            .height(34)
            .width(100)
            .enabled(this.getSelectedCount() > 0)
            .onClick(() => this.deleteSelected())
        } else {
          // 正常模式：合计 + 结算
          Column() {
            Row() {
              Text('合计: ')
                .fontSize(13)
                .fontColor('#333')
              Text(`¥${this.getTotalPrice()}`)
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF4D4F')
            }

            if (this.getSelectedItemCount() > 0) {
              Text(`共 ${this.getSelectedItemCount()} 件`)
                .fontSize(11)
                .fontColor('#999')
                .margin({ top: 2 })
            }
          }
          .alignItems(HorizontalAlign.End)
          .margin({ right: 16 })

          Button(`结算(${this.getSelectedCount()})`)
            .fontSize(14)
            .backgroundColor(this.getSelectedCount() > 0 ? '#FF4D4F' : '#FFB3B3')
            .fontColor(Color.White)
            .borderRadius(20)
            .height(38)
            .width(88)
            .enabled(this.getSelectedCount() > 0)
            .onClick(() => {
              if (this.getSelectedCount() > 0) {
                router.pushUrl({ url: 'pages/OrderListPage' });
              }
            })
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 12 })
    }
    .width('100%')
    .backgroundColor(Color.White)
  }

  build() {
    Column() {
      // 顶部导航栏
      this.NavBar()

      if (this.isLoading) {
        this.LoadingView()
      } else if (this.cartItems.length === 0) {
        this.EmptyCart()
      } else {
        // 购物车列表
        Scroll() {
          Column() {
            ForEach(this.cartItems, (item: CartItem, index: number) => {
              this.CartItemCard(item)
            }, (item: CartItem, index: number) => item.cartId + '_' + item.selected + '_' + item.quantity + '_' + index)
          }
          .padding(12)
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .backgroundColor('#F5F5F5')

        // 底部结算栏
        this.BottomBar()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
