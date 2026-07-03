import { ProductService } from '../services/product/ProductService';
import { CategoryService } from '../services/product/CategoryService';
import { CartService } from '../services/cart/CartService';
import { OrderService } from '../services/order/OrderService';
import { UserService } from '../services/user/UserService';
import { AuthManager } from '../services/auth/AuthManager';
import { Product, Category, CartItem, Order, OrderItem, User } from '../common/models';
import { ProductCard } from '../components/ProductCard';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0;
  @State tabUser: User | null = null;
  private tabTitles: string[] = ['首页', '购物车', '订单', '我的'];

  aboutToAppear(): void {
    this.loadTabUser();
  }

  onPageShow(): void {
    this.loadTabUser();
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
        HomeTab()
      }
      .tabBar(this.TabBuilder(0))

      TabContent() {
        CartTab()
      }
      .tabBar(this.TabBuilder(1))

      TabContent() {
        OrderTab()
      }
      .tabBar(this.TabBuilder(2))

      TabContent() {
        UserTab({ userData: this.tabUser, onChangeLogout: () => { this.tabUser = null; } })
      }
      .tabBar(this.TabBuilder(3))
    }
    .onChange((index: number) => {
      this.currentTabIndex = index;
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
  @State products: Product[] = [];
  @State categories: Category[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      const catService: CategoryService = CategoryService.getInstance();
      const prodService: ProductService = ProductService.getInstance();
      const cats: Category[] = await catService.getAllCategories();
      const prods: Product[] = await prodService.getAllProducts();
      this.categories = cats;
      this.products = prods;
    } catch (e) {
      this.products = [];
      this.categories = [];
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      Search({ placeholder: '搜索商品' })
        .width('100%')
        .height(40)
        .backgroundColor('#F0F0F0')
        .borderRadius(20)
        .margin({ left: 12, right: 12, top: 36, bottom: 4 })

      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.categories, (cat: Category) => {
            Text(cat.name)
              .fontSize(13)
              .fontColor('#333')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .borderRadius(14)
              .backgroundColor('#F5F5F5')
          }, (cat: Category) => cat.categoryId)
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(40)

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
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.products, (product: Product) => {
              ProductCard({
                product: product,
                onCardClick: () => {
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
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

@Component
struct CartTab {
  @State cartItems: CartItem[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadCart();
  }

  async loadCart(): Promise<void> {
    this.isLoading = true;
    try {
      const service: CartService = CartService.getInstance();
      const items: CartItem[] = await service.getCartItems('default_user');
      this.cartItems = items;
    } catch (e) {
      this.cartItems = [];
    }
    this.isLoading = false;
  }

  getTotalPrice(): number {
    let total: number = 0;
    for (let i: number = 0; i < this.cartItems.length; i++) {
      total += this.cartItems[i].price * this.cartItems[i].quantity;
    }
    return total;
  }

  build() {
    Column() {
      Text('购物车')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height(48)
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.White)
        .padding({ top: 36 })

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
          Text('购物车是空的').fontSize(16).fontColor('#999')
          Text('快去逛逛吧').fontSize(14).fontColor('#999').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.cartItems, (item: CartItem) => {
              Row() {
                if (item.productImage) {
                  Image(item.productImage)
                    .width(80)
                    .height(80)
                    .borderRadius(6)
                    .alt($r('app.media.app_icon'))
                } else {
                  Column().width(80).height(80).borderRadius(6).backgroundColor('#F0F0F0')
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
          Text(`合计: ¥${this.getTotalPrice()}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF4D4F')
            .layoutWeight(1)

          Button('去结算')
            .fontSize(14)
            .backgroundColor('#FF4D4F')
            .borderRadius(20)
            .height(36)
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

@Component
struct OrderTab {
  @State orders: Order[] = [];
  @State isLoading: boolean = true;

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

  getStatusText(status: number): string {
    if (status === 0) { return '待付款'; }
    if (status === 1) { return '待发货'; }
    if (status === 2) { return '待收货'; }
    if (status === 3) { return '已完成'; }
    return '已取消';
  }

  build() {
    Column() {
      Text('我的订单')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height(48)
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.White)
        .padding({ top: 36 })

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(36).height(36)
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.orders.length === 0) {
        Column() {
          Text('暂无订单').fontSize(16).fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.orders, (order: Order) => {
              Column() {
                Row() {
                  Text(`订单号: ${order.orderNo}`)
                    .fontSize(13)
                    .fontColor('#666')
                  Text(this.getStatusText(order.status))
                    .fontSize(13)
                    .fontColor('#FF4D4F')
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
                  Text(`共 ${order.items ? order.items.length : 0} 件 合计: `)
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
                .fontSize(20)
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
            .fontSize(14)
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
