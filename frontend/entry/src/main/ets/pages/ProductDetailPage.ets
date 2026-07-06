import { ProductService } from '../services/product/ProductService';
import { FavoriteService } from '../services/product/FavoriteService';
import { ReviewService } from '../services/product/ReviewService';
import { CartService } from '../services/cart/CartService';
import { Product, ProductSpec, Review } from '../common/models';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct ProductDetailPage {
  @State product: Product | null = null;
  @State quantity: number = 1;
  @State isLoading: boolean = true;
  @State isCollected: boolean = false;
  @State reviews: Review[] = [];
  @State selectedSpecs: Record<string, number> = {};
  private productId: string = '';

  aboutToAppear(): void {
    const params: Record<string, Object> = router.getParams() as Record<string, Object>;
    if (params && params['productId']) {
      this.productId = params['productId'] as string;
      this.loadProduct();
      this.loadReviews();
      this.checkFavorite();
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

  async loadReviews(): Promise<void> {
    try {
      const reviewService: ReviewService = ReviewService.getInstance();
      this.reviews = await reviewService.getProductReviews(this.productId);
    } catch (e) {
      this.reviews = [];
    }
  }

  async checkFavorite(): Promise<void> {
    try {
      const favoriteService: FavoriteService = FavoriteService.getInstance();
      this.isCollected = await favoriteService.checkFavorite(this.productId);
    } catch (e) {
      this.isCollected = false;
    }
  }

  async toggleFavorite(): Promise<void> {
    try {
      const favoriteService: FavoriteService = FavoriteService.getInstance();
      const collected: boolean = await favoriteService.toggleFavorite(this.productId);
      this.isCollected = collected;
      if (collected) {
        promptAction.showToast({ message: '已收藏' });
      } else {
        promptAction.showToast({ message: '已取消收藏' });
      }
    } catch (e) {
      promptAction.showToast({ message: '操作失败' });
    }
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

  getStars(rating: number): string {
    const fullStars: number = Math.floor(rating);
    const halfStar: boolean = rating - fullStars >= 0.5;
    let stars: string = '';
    for (let i: number = 0; i < fullStars; i++) {
      stars += '⭐';
    }
    if (halfStar) {
      stars += '☆';
    }
    return stars;
  }

  formatTime(timestamp: number): string {
    const date: Date = new Date(timestamp);
    const month: string = String(date.getMonth() + 1).padStart(2, '0');
    const day: string = String(date.getDate()).padStart(2, '0');
    return month + '-' + day;
  }

  @Builder
  SpecSelector() {
    if (this.product && this.product.specs && this.product.specs.length > 0) {
      Column() {
        Text('规格')
          .fontSize(14)
          .fontColor('#333')
          .fontWeight(FontWeight.Medium)

        ForEach(this.product.specs, (spec: ProductSpec, index: number) => {
          Row() {
            Text(spec.name + ':')
              .fontSize(13)
              .fontColor('#666')
              .width(60)

            Row() {
              if (spec.values && spec.values.length > 0) {
                ForEach(spec.values, (value: string, vi: number) => {
                  Text(value)
                    .fontSize(12)
                    .fontColor(this.selectedSpecs[index.toString()] === vi ? '#FF4D4F' : '#333')
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .backgroundColor(this.selectedSpecs[index.toString()] === vi ? '#FFF1F0' : '#F5F5F5')
                    .border({
                      width: 1,
                      color: this.selectedSpecs[index.toString()] === vi ? '#FF4D4F' : '#E0E0E0',
                      radius: 4
                    })
                    .margin({ right: 8, top: 4 })
                    .onClick(() => {
                      const newSpecs: Record<string, number> = {};
                      const keys: string[] = Object.keys(this.selectedSpecs);
                      for (let k: number = 0; k < keys.length; k++) {
                        newSpecs[keys[k]] = this.selectedSpecs[keys[k]];
                      }
                      newSpecs[index.toString()] = vi;
                      this.selectedSpecs = newSpecs;
                    })
                })
              }
            }
            .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: 8 })
          .alignItems(VerticalAlign.Center)
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .margin({ top: 8 })
      .alignItems(HorizontalAlign.Start)
      .borderRadius(10)
    }
  }

  @Builder
  ReviewSection() {
    Column() {
      Row() {
        Text('用户评价')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')

        Text(' (' + this.reviews.length.toString() + ')')
          .fontSize(13)
          .fontColor('#999')
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      if (this.reviews.length === 0) {
        Column() {
          Text('暂无评价')
            .fontSize(13)
            .fontColor('#CCC')
            .margin({ top: 20, bottom: 20 })
          Text('成为第一个评价的人吧')
            .fontSize(13)
            .fontColor('#CCC')
        }
        .width('100%')
      } else {
        ForEach(this.reviews.slice(0, 5), (review: Review) => {
          Column() {
            Row() {
              Text(review.userName)
                .fontSize(13)
                .fontColor('#666')
              Text(this.getStars(review.rating))
                .fontSize(12)
                .margin({ left: 8 })
              Blank()
              Text(this.formatTime(review.createdAt))
                .fontSize(11)
                .fontColor('#CCC')
            }
            .width('100%')

            if (review.content) {
              Text(review.content)
                .fontSize(13)
                .fontColor('#333')
                .maxLines(3)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')
                .margin({ top: 8 })
            }
          }
          .width('100%')
          .padding({ top: 12, bottom: 12 })
          .border({ width: { bottom: review !== this.reviews[this.reviews.length - 1] ? 0.5 : 0 }, color: '#F0F0F0' })
          .alignItems(HorizontalAlign.Start)
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ top: 8 })
    .borderRadius(10)
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

        Text(this.isCollected ? '❤' : '♡')
          .fontSize(22)
          .fontColor(this.isCollected ? '#FF4D4F' : '#999')
          .onClick(() => { this.toggleFavorite(); })
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
                Text(`￥${this.product.price}`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF4D4F')

                if (this.product.originalPrice && this.product.originalPrice > this.product.price) {
                  Text(`￥${this.product.originalPrice}`)
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
                Text('已售 ' + this.product.salesCount)
                  .fontSize(12)
                  .fontColor('#999')
                Text('评分 ' + this.product.rating)
                  .fontSize(12)
                  .fontColor('#999')
                  .margin({ left: 16 })
                Text('库存 ' + this.product.stock)
                  .fontSize(12)
                  .fontColor('#999')
                  .margin({ left: 16 })
              }
              .margin({ top: 12 })
              .width('100%')

              if (this.product.brand) {
                Text('品牌: ' + this.product.brand)
                  .fontSize(13)
                  .fontColor('#666')
                  .margin({ top: 8 })
              }
            }
            .padding(16)
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .backgroundColor(Color.White)

            this.SpecSelector()
            this.ReviewSection()
          }
          .width('100%')
          .padding({ bottom: 56 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#F5F5F5')

        Row() {
          Row() {
            Text('数量')
              .fontSize(14)
              .fontColor('#333')

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
