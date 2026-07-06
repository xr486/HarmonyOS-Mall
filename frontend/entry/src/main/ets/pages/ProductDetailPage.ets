import { ProductService } from '../services/product/ProductService';
import { CartService } from '../services/cart/CartService';
import { Product } from '../common/models';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct ProductDetailPage {
  @State product: Product | null = null;
  @State quantity: number = 1;
  @State isLoading: boolean = true;
  private productId: string = '';

  aboutToAppear(): void {
    const params: Record<string, Object> = router.getParams() as Record<string, Object>;
    if (params && params['productId']) {
      this.productId = params['productId'] as string;
      this.loadProduct();
    }
  }

  async loadProduct(): Promise<void> {
    this.isLoading = true;
    try {
      const service: ProductService = ProductService.getInstance();
      const result: Product | null = await service.getProductById(this.productId);
      this.product = result;
    } catch (e) {
      this.product = null;
    }
    this.isLoading = false;
  }

  async addToCart(): Promise<void> {
    if (!this.product) {
      return;
    }
    try {
      const cartService: CartService = CartService.getInstance();
      const success: boolean = await cartService.addToCart({
        cartId: `cart_${Date.now()}`,
        userId: 'default_user',
        productId: this.product.productId,
        productName: this.product.name,
        productImage: this.product.images && this.product.images.length > 0 ? this.product.images[0] : '',
        price: this.product.price,
        quantity: this.quantity,
        selected: true,
        stock: this.product.stock,
        addedAt: Date.now()
      });
      if (success) {
        promptAction.showToast({ message: '已加入购物车' });
      } else {
        promptAction.showToast({ message: '加入失败，请重试' });
      }
    } catch (e) {
      promptAction.showToast({ message: '网络异常，请重试' });
    }
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(22)
          .onClick(() => { router.back(); })
        Text('商品详情')
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
      } else if (this.product) {
        Scroll() {
          Column() {
            if (this.product.images && this.product.images.length > 0) {
              Image(this.product.images[0])
                .width('100%')
                .height(300)
                .objectFit(ImageFit.Cover)
                .alt($r('app.media.app_icon'))
            }

            Column() {
              Row() {
                Text(`¥${this.product.price}`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF4D4F')

                if (this.product.originalPrice && this.product.originalPrice > this.product.price) {
                  Text(`¥${this.product.originalPrice}`)
                    .fontSize(14)
                    .fontColor('#999')
                    .decoration({ type: TextDecorationType.LineThrough })
                    .margin({ left: 8 })
                }
              }
              .margin({ top: 16 })

              Text(this.product.name)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 12 })
                .width('100%')

              Text(this.product.description)
                .fontSize(14)
                .fontColor('#666')
                .margin({ top: 8 })
                .width('100%')

              Row() {
                Text(`已售 ${this.product.salesCount}`)
                  .fontSize(12)
                  .fontColor('#999')
                Text(`评分 ${this.product.rating}`)
                  .fontSize(12)
                  .fontColor('#999')
                  .margin({ left: 16 })
                Text(`库存 ${this.product.stock}`)
                  .fontSize(12)
                  .fontColor('#999')
                  .margin({ left: 16 })
              }
              .margin({ top: 12 })
              .width('100%')

              if (this.product.brand) {
                Text(`品牌: ${this.product.brand}`)
                  .fontSize(13)
                  .fontColor('#666')
                  .margin({ top: 8 })
              }
            }
            .padding(16)
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#F5F5F5')

        Row() {
          Row() {
            Text('数量')
              .fontSize(14)
              .fontColor('#333')

            // 数量调整器
            Row() {
              Text('-')
                .fontSize(16)
                .fontColor('#666')
                .width(32)
                .height(32)
                .textAlign(TextAlign.Center)
                .borderRadius(4)
                .backgroundColor('#F5F5F5')
                .onClick(() => {
                  if (this.quantity > 1) { this.quantity--; }
                })

              Text(this.quantity.toString())
                .fontSize(15)
                .fontColor('#333')
                .width(44)
                .height(32)
                .textAlign(TextAlign.Center)

              Text('+')
                .fontSize(16)
                .fontColor('#666')
                .width(32)
                .height(32)
                .textAlign(TextAlign.Center)
                .borderRadius(4)
                .backgroundColor('#F5F5F5')
                .onClick(() => {
                  if (this.quantity < (this.product ? this.product.stock : 99)) {
                    this.quantity++;
                  }
                })
            }
            .border({ width: 1, color: '#E0E0E0', radius: 6 })
          }

          Button('加入购物车')
            .fontSize(14)
            .backgroundColor('#FF4D4F')
            .borderRadius(20)
            .layoutWeight(1)
            .margin({ left: 12 })
            .onClick(() => { this.addToCart(); })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
      } else {
        Column() {
          Text('商品不存在')
            .fontSize(16)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}
