import { HomepageService } from '../services/product/HomepageService';
import { RecommendationTrackService } from '../services/product/RecommendationTrackService';
import { Product } from '../common/models';
import { ProductCard } from '../components/ProductCard';
import router from '@ohos.router';

@Entry
@Component
struct RecommendationPage {
  @State products: Product[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadAll();
  }

  async loadAll(): Promise<void> {
    this.isLoading = true;
    try {
      const service: HomepageService = HomepageService.getInstance();
      let prods: Product[] = await service.getHomepageRecommendations('default_user');
      if (prods.length === 0) {
        prods = await service.getHotProducts(20);
      }
      this.products = prods;
    } catch (e) {
      this.products = [];
    }
    this.isLoading = false;
  }

  trackClick(productId: string, index: number): void {
    const trackService: RecommendationTrackService = RecommendationTrackService.getInstance();
    trackService.trackClick(productId, 'recommend_page', index, 'recommend');
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .onClick(() => router.back())

        Text('为你推荐')
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

      Text('根据最近浏览的商品推荐同类好物')
        .fontSize(12)
        .fontColor('#999')
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 4, bottom: 8 })
        .backgroundColor(Color.White)

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(36).height(36).color('#FF4D4F')
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else if (this.products.length === 0) {
        Column() {
          Text('暂无推荐').fontSize(16).fontColor('#999')
          Text('浏览商品后为你推荐同类好物').fontSize(13).fontColor('#BBB').margin({ top: 8 })
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
          .padding({ left: 12, right: 12, top: 12 })
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
