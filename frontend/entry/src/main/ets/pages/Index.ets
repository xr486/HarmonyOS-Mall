import { ProductService } from '../services/product/ProductService';
import { CategoryService } from '../services/product/CategoryService';
import { HomepageService } from '../services/product/HomepageService';
import { RecommendationTrackService } from '../services/product/RecommendationTrackService';
import { CartService } from '../services/cart/CartService';
import { OrderService } from '../services/order/OrderService';
import { UserService } from '../services/user/UserService';
import { AuthManager } from '../services/auth/AuthManager';
import { Product, Category, CartItem, Order, OrderItem, User } from '../common/models';
import { ProductCard } from '../components/ProductCard';
import { OrderRefreshUtil } from '../common/utils/OrderRefreshUtil';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0;
  @State tabUser: User | null = null;
  @State cartRefreshKey: number = 0;
  @State orderRefreshKey: number = 0;
  @State recommendRefreshKey: number = 0;
  private tabTitles: string[] = ['首页', '推荐', '购物车', '订单', '我的'];

  aboutToAppear(): void {
    this.loadTabUser();
  }

  onPageShow(): void {
    this.loadTabUser();
    this.recommendRefreshKey++;
  }

  onTabChange(index: number): void {
    if (index === 1) {
      this.recommendRefreshKey++;
    }
    if (index === 2) {
      this.cartRefreshKey++;
    }
    if (index === 3) {
      this.orderRefreshKey++;
    }
    this.currentTabIndex = index;
  }

  async loadTabUser(): Promise<void> {
    try {
      const auth: AuthManager = AuthManager.getInstance();
      const loggedIn: boolean = await auth.isLoggedIn();
      if (!loggedIn) {
        this.tabUser = null;
        return;
      }
      const result: Object | null = await auth.getCurrentUser();
      this.tabUser = result ? (result as User) : null;
    } catch (e) {
      this.tabUser = null;
    }
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentTabIndex }) {
      TabContent() {
        HomeTab({ refreshKey: this.recommendRefreshKey })
      }
      .tabBar(this.TabBuilder(0))

      TabContent() {
        RecommendTab({ refreshKey: this.recommendRefreshKey })
      }
      .tabBar(this.TabBuilder(1))

      TabContent() {
        CartTab({ refreshKey: this.cartRefreshKey })
      }
      .tabBar(this.TabBuilder(2))

      TabContent() {
        OrderTab({ refreshKey: this.orderRefreshKey })
      }
      .tabBar(this.TabBuilder(3))

      TabContent() {
        UserTab({ userData: this.tabUser, onChangeLogout: () => { this.tabUser = null; } })
      }
      .tabBar(this.TabBuilder(4))
    }
    .onChange((index: number) => {
      this.onTabChange(index);
    })
    .barHeight(56)
    .width('100%')
    .height('100%')
  }

  @Builder
  TabBuilder(index: number) {
    Column() {
      if (index === this.currentTabIndex) {
        Text(this.tabTitles[index])
          .fontSize(12)
          .fontColor('#FF4D4F')
          .fontWeight(FontWeight.Medium)
      } else {
        Text(this.tabTitles[index])
          .fontSize(12)
          .fontColor('#999')
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct HomeTab {
  @Prop @Watch('onRefreshKeyChanged') refreshKey: number = 0;
  @State products: Product[] = [];
  @State categories: Category[] = [];
  @State isLoading: boolean = true;
  @State isRefreshing: boolean = false;

  aboutToAppear(): void {
    this.loadData();
  }

  onRefreshKeyChanged(): void {
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      const catService: CategoryService = CategoryService.getInstance();
      const prodService: ProductService = ProductService.getInstance();
      const cats: Category[] = await catService.getAllCategories();
      const prods: Product[] = await prodService.getAllProducts();
      this.categories = cats.filter((c: Category) => !c.parentId);
      this.products = prods;
    } catch (e) {
      this.products = [];
      this.categories = [];
    }
    this.isLoading = false;
  }

  async refreshData(): Promise<void> {
    this.isRefreshing = true;
    try {
      const catService: CategoryService = CategoryService.getInstance();
      const prodService: ProductService = ProductService.getInstance();
      const cats: Category[] = await catService.getAllCategories();
      const prods: Product[] = await prodService.getAllProducts();
      this.categories = cats.filter((c: Category) => !c.parentId);
      this.products = prods;
    } catch (e) {
      this.products = [];
      this.categories = [];
    }
    this.isRefreshing = false;
  }

  trackProductClick(productId: string, index: number): void {
    const trackService: RecommendationTrackService = RecommendationTrackService.getInstance();
    trackService.trackClick(productId, 'mixed', index, 'homepage');
  }

  build() {
    Column() {
      Row() {
        Search({ placeholder: '搜索商品' })
          .width('85%')
          .height(40)
          .backgroundColor('#F0F0F0')
          .borderRadius(20)
          .onClick(() => {
            router.pushUrl({ url: 'pages/SearchPage' });
          })
        Column() {
          if (this.isRefreshing) {
            LoadingProgress()
              .width(24)
              .height(24)
              .color('#FF4D4F')
          } else {
            Text('刷新')
              .fontSize(12)
              .fontColor('#FF4D4F')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(12)
              .backgroundColor('#FFF1F0')
          }
        }
        .width(36)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          if (!this.isRefreshing) {
            this.refreshData();
          }
        })
      }
      .padding({ left: 12, right: 12, top: 36, bottom: 4 })

      Row({ space: 12 }) {
        Text('全部分类')
          .fontSize(13)
          .fontColor('#FF4D4F')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .borderRadius(14)
          .backgroundColor('#FFF1F0')
          .onClick(() => {
            router.pushUrl({ url: 'pages/CategoryPage' });
          })

        Text('附近好物')
          .fontSize(13)
          .fontColor('#1890FF')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .borderRadius(14)
          .backgroundColor('#E6F7FF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/NearbyPage' });
          })

        ForEach(this.categories.slice(0, 5), (cat: Category) => {
          Text(cat.name)
            .fontSize(13)
            .fontColor('#333')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .borderRadius(14)
            .backgroundColor('#F5F5F5')
            .onClick(() => {
              router.pushUrl({
                url: 'pages/ProductListPage',
                params: { categoryId: cat.categoryId, categoryName: cat.name }
              });
            })
        }, (cat: Category) => cat.categoryId)
      }
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .width('100%')

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(36).height(36)
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.products, (product: Product, index: number) => {
                ProductCard({
                  product: product,
                  onCardClick: () => {
                    this.trackProductClick(product.productId, index);
                    router.pushUrl({
                      url: 'pages/ProductDetailPage',
                      params: { productId: product.productId }
                    });
                  }
                })
              }, (product: Product) => product.productId)
            }
            .padding({ left: 8, right: 8, top: 8 })
            .width('100%')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

function cloneCartItem(
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

@Component
struct RecommendTab {
  @Prop @Watch('onRefreshKeyChanged') refreshKey: number = 0;
  @State products: Product[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadData();
  }

  onRefreshKeyChanged(): void {
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      const homepageService: HomepageService = HomepageService.getInstance();
      let prods: Product[] = await homepageService.getHomepageRecommendations('default_user');
      if (prods.length === 0) {
        prods = await homepageService.getHotProducts(20);
      }
      this.products = prods;
    } catch (e) {
      this.products = [];
    }
    this.isLoading = false;
  }

  trackClick(productId: string, index: number): void {
    const trackService: RecommendationTrackService = RecommendationTrackService.getInstance();
    trackService.trackClick(productId, 'recommend_tab', index, 'recommend');
  }

  build() {
    Column() {
      Row() {
        Text('为你推荐')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
        Text('根据浏览记录匹配同类商品')
          .fontSize(12)
          .fontColor('#999')
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .backgroundColor(Color.White)

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(36).height(36).color('#FF4D4F')
          Text('加载推荐中...').fontSize(14).fontColor('#999').margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else if (this.products.length === 0) {
        Column() {
          Text('暂无推荐')
            .fontSize(16).fontColor('#999')
          Text('浏览商品后为你推荐同类好物')
            .fontSize(13).fontColor('#BBB').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else {
        Scroll() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.products, (product: Product, index: number) => {
              ProductCard({
                product: product,
                onCardClick: () => {
                  this.trackClick(product.productId, index);
                  router.pushUrl({
                    url: 'pages/ProductDetailPage',
                    params: { productId: product.productId }
                  });
                }
              })
            }, (product: Product) => product.productId)
          }
          .padding({ left: 8, right: 8, top: 8 })
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

@Component
struct CartTab {
  @Link @Watch('onRefreshKeyChange') refreshKey: number;
  @StorageLink(OrderRefreshUtil.getKey()) @Watch('onOrderRefresh') orderRefreshTrigger: number = 0;
  @State cartItems: CartItem[] = [];
  @State isLoading: boolean = true;
  @State allSelected: boolean = true;
  @State isEditing: boolean = false;
  private isInitialized: boolean = false;

  onRefreshKeyChange(): void {
    if (this.isInitialized) {
      this.loadCart();
    }
  }

  onOrderRefresh(): void {
    if (this.isInitialized) {
      this.loadCart();
    }
  }

  aboutToAppear(): void {
    this.isInitialized = true;
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
    let all: boolean = true;
    for (let i: number = 0; i < this.cartItems.length; i++) {
      if (!this.cartItems[i].selected) {
        all = false;
        break;
      }
    }
    this.allSelected = all;
  }

  async toggleAllSelected(): Promise<void> {
    const newChecked: boolean = !this.allSelected;
    const newItems: CartItem[] = [];
    for (let i: number = 0; i < this.cartItems.length; i++) {
      newItems.push(cloneCartItem(this.cartItems[i], newChecked));
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
        rollback.push(cloneCartItem(this.cartItems[i], !newChecked));
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
        newItems.push(cloneCartItem(it, newChecked));
      } else {
        newItems.push(cloneCartItem(it));
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
          rollback.push(cloneCartItem(it, !newChecked));
        } else {
          rollback.push(cloneCartItem(it));
        }
      }
      this.cartItems = rollback;
      this.updateAllSelected();
      promptAction.showToast({ message: '网络异常，请重试' });
    }
  }

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

    const newItems: CartItem[] = [];
    for (let i: number = 0; i < this.cartItems.length; i++) {
      const it: CartItem = this.cartItems[i];
      if (it.cartId === cartId) {
        newItems.push(cloneCartItem(it, undefined, newQty));
      } else {
        newItems.push(cloneCartItem(it));
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
          rollback.push(cloneCartItem(it, undefined, target.quantity));
        } else {
          rollback.push(cloneCartItem(it));
        }
      }
      this.cartItems = rollback;
      promptAction.showToast({ message: '网络异常，请重试' });
    }
  }

  async deleteItem(cartId: string): Promise<void> {
    const service: CartService = CartService.getInstance();
    const success: boolean = await service.removeFromCart(cartId);
    if (success) {
      const newItems: CartItem[] = [];
      for (let i: number = 0; i < this.cartItems.length; i++) {
        if (this.cartItems[i].cartId !== cartId) {
          newItems.push(cloneCartItem(this.cartItems[i]));
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

  getSelectedItemCount(): number {
    let count: number = 0;
    for (let i: number = 0; i < this.cartItems.length; i++) {
      if (this.cartItems[i].selected) {
        count += this.cartItems[i].quantity;
      }
    }
    return count;
  }

  goToDetail(productId: string): void {
    router.pushUrl({
      url: 'pages/ProductDetailPage',
      params: { productId: productId }
    });
  }

  @Builder
  CartItemCard(item: CartItem) {
    Row() {
      Checkbox({ name: item.cartId })
        .select(item.selected)
        .shape(CheckBoxShape.ROUNDED_SQUARE)
        .selectedColor('#FF4D4F')
        .onChange((value: boolean) => {
          if (value !== item.selected) {
            this.toggleItem(item.cartId);
          }
        })
        .margin({ right: 8 })

      Image(item.productImage || '')
        .width(80)
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
        .alt($r('app.media.app_icon'))
        .onClick(() => this.goToDetail(item.productId))

      Column() {
        Column() {
          Text(item.productName)
            .fontSize(14)
            .fontColor('#333')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .onClick(() => this.goToDetail(item.productId))

          if (item.specs && item.specs.length > 0) {
            Text(item.specs)
              .fontSize(12)
              .fontColor('#999')
              .margin({ top: 4 })
              .width('100%')
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text(`¥${item.price}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF4D4F')

          if (this.isEditing) {
            Text('删除')
              .fontSize(12)
              .fontColor('#FF4D4F')
              .padding({ left: 12, right: 12, top: 5, bottom: 5 })
              .border({ width: 1, color: '#FF4D4F', radius: 14 })
              .onClick(() => this.deleteItem(item.cartId))
          } else {
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
      }
      .layoutWeight(1)
      .height(80)
      .margin({ left: 10 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 0, bottom: 6 })
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ left: 8, right: 8, bottom: 6 })
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  BottomBar() {
    Column() {
      Divider().color('#EEE').strokeWidth(1)

      Row() {
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
                const selectedIds: string[] = [];
                for (let i: number = 0; i < this.cartItems.length; i++) {
                  if (this.cartItems[i].selected) {
                    selectedIds.push(this.cartItems[i].cartId);
                  }
                }
                router.pushUrl({
                  url: 'pages/OrderConfirmPage',
                  params: { cartIds: selectedIds }
                });
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
      Row() {
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

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(36).height(36)
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.cartItems.length === 0) {
        Column() {
          Text('🛒')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('购物车是空的').fontSize(16).fontColor('#333').fontWeight(FontWeight.Medium)
          Text('快去挑选心仪的商品吧~').fontSize(13).fontColor('#999').margin({ top: 6 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.cartItems, (item: CartItem, index: number) => {
              this.CartItemCard(item)
            }, (item: CartItem, index: number) => item.cartId + '_' + item.selected + '_' + item.quantity + '_' + index)
          }
          .padding(0)
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .backgroundColor('#F5F5F5')

        this.BottomBar()
      }
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct OrderTab {
  @Link @Watch('onRefreshKeyChange') refreshKey: number;
  @StorageLink(OrderRefreshUtil.getKey()) @Watch('onOrderRefresh') orderRefreshTrigger: number = 0;
  @State orders: Order[] = [];
  @State isLoading: boolean = true;
  @State activeTab: number = 0;
  private isInitialized: boolean = false;

  private tabItems: string[] = ['全部', '待付款', '待发货', '待收货', '已完成', '已取消'];

  onRefreshKeyChange(): void {
    if (this.isInitialized) {
      this.loadOrders();
    }
  }

  onOrderRefresh(): void {
    if (this.isInitialized) {
      this.loadOrders();
    }
  }

  aboutToAppear(): void {
    this.isInitialized = true;
    this.loadOrders();
  }

  async loadOrders(): Promise<void> {
    this.isLoading = true;
    try {
      const service: OrderService = OrderService.getInstance();
      const status: number = this.activeTab;
      const allOrders: Order[] = await service.getAllOrders('default_user', status === 0 ? undefined : status - 1);
      this.orders = allOrders;
    } catch (e) {
      this.orders = [];
    }
    this.isLoading = false;
  }

  onTabChanged(index: number): void {
    this.activeTab = index;
    this.loadOrders();
  }

  getStatusText(status: number): string {
    if (status === 0) { return '待付款'; }
    if (status === 1) { return '待发货'; }
    if (status === 2) { return '待收货'; }
    if (status === 3) { return '已完成'; }
    return '已取消';
  }

  getStatusColor(status: number): string {
    if (status === 0) { return '#FF4D4F'; }
    if (status === 1) { return '#FAAD14'; }
    if (status === 2) { return '#1890FF'; }
    if (status === 3) { return '#52C41A'; }
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

  @Builder
  OrderCard(order: Order) {
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

      Divider().color('#F0F0F0').strokeWidth(1)

      if (order.items && order.items.length > 0) {
        ForEach(order.items.slice(0, 2), (item: OrderItem) => {
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

      if (order.items && order.items.length > 2) {
        Text(`等 ${order.items.length} 件商品`)
          .fontSize(12)
          .fontColor('#999')
          .width('100%')
          .textAlign(TextAlign.End)
          .margin({ top: 4, bottom: 4 })
      }

      Divider().color('#F0F0F0').strokeWidth(1)

      Row() {
        Text(`共 ${this.getItemCount(order)} 件商品`)
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
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ bottom: 10 })
    .onClick(() => { this.goToDetail(order.orderId); })
  }

  build() {
    Column() {
      // 状态栏 + 标题
      Row()
        .width('100%')
        .height(12)
        .backgroundColor(Color.White)

      Text('我的订单')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height(48)
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.White)

      Row() {
        ForEach(this.tabItems, (label: string, index: number) => {
          Column() {
            Text(label)
              .fontSize(13)
              .fontColor(this.activeTab === index ? '#FF4D4F' : '#333')
              .fontWeight(this.activeTab === index ? FontWeight.Medium : FontWeight.Normal)
              .padding({ top: 8, bottom: 6 })

            if (this.activeTab === index) {
              Row()
                .width(16)
                .height(3)
                .backgroundColor('#FF4D4F')
                .borderRadius(2)
            } else {
              Row()
                .width(16)
                .height(3)
                .backgroundColor(Color.Transparent)
            }
          }
          .onClick(() => { this.onTabChanged(index); })
        }, (label: string, index: number) => label + '_' + index)
      }
      .width('100%')
      .height(40)
      .padding({ left: 8, right: 8 })
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceAround)

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(36).height(36)
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else if (this.orders.length === 0) {
        Column() {
          Text('暂无订单').fontSize(16).fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else {
          Scroll() {
            Column() {
              ForEach(this.orders, (order: Order) => {
                this.OrderCard(order)
              }, (order: Order) => order.orderId)
            }
            .padding({ left: 12, right: 12, bottom: 12 })
            .width('100%')
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
  }
}

@Component
struct UserTab {
  @Prop userData: User | null = null;
  onChangeLogout?: () => void;

  build() {
    Column() {
      Text('我的')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height(48)
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.White)
        .padding({ top: 36 })

      Scroll() {
        Column() {
          Row() {
            Column() {
              Circle().width(60).height(60).fill('#FF4D4F')
            }
            Column() {
              Text(this.userData ? this.userData.nickname : '未登录')
                .fontWeight(FontWeight.Bold)
              Text(this.userData ? this.userData.phone : '点击登录')
                .fontSize(14)
                .fontColor('#999')
                .margin({ top: 4 })
            }
            .margin({ left: 16 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 10 })
          .onClick(() => {
            if (!this.userData) {
              router.pushUrl({ url: 'pages/Login' });
            } else {
              router.pushUrl({ url: 'pages/UserInfo' });
            }
          })

          Column() {
            Row() {
              Text('我的订单').fontSize(15)
              Text('>').fontSize(14).fontColor('#CCC')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/OrderListPage' });
            })
            Divider().margin({ left: 16 })
            Row() {
              Text('收货地址').fontSize(15)
              Text('>').fontSize(14).fontColor('#CCC')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/AddressList' });
            })
            Divider().margin({ left: 16 })
            Row() {
              Text('我的收藏').fontSize(15)
              Text('>').fontSize(14).fontColor('#CCC')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 10 })

          Column() {
            Row() {
              Text('设置').fontSize(15)
              Text('>').fontSize(14).fontColor('#CCC')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            Divider().margin({ left: 16 })
            Row() {
              Text('帮助中心').fontSize(15)
              Text('>').fontSize(14).fontColor('#CCC')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)

          Button('退出登录')
            .backgroundColor('#FFF1F0')
            .fontColor('#FF4D4F')
            .width('100%')
            .height(44)
            .borderRadius(22)
            .margin({ top: 30 })
            .onClick(async () => {
              const auth: AuthManager = AuthManager.getInstance();
              await auth.signOut();
              if (this.onChangeLogout) {
                this.onChangeLogout();
              }
              promptAction.showToast({ message: '已退出登录' });
            })
        }
        .padding(12)
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }
}
