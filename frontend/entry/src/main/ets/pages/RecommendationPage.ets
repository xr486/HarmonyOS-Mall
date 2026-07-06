import { RecommendationService } from '../services/product/RecommendationService';
import { RecommendationItem } from '../common/models';
import { ProductCard } from '../components/ProductCard';
import router from '@ohos.router';

@Entry
@Component
struct RecommendationPage {
  @State recommendations: RecommendationItem[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadAll();
  }

  async loadAll(): Promise<void> {
    this.isLoading = true;
    try {
      const service: RecommendationService = RecommendationService.getInstance();
      const recs: RecommendationItem[] = await service.getRecommendations('default_user');
      this.recommendations = recs;
    } catch (e) {
      this.recommendations = [];
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      // 顶部导航栏
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

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(36).height(36).color('#FF4D4F')
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.recommendations.length === 0) {
        Column() {
          Text('暂无推荐').fontSize(16).fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.recommendations, (rec: RecommendationItem) => {
              ProductCard({
                product: rec.product,
                showRecommendTag: true,
                onCardClick: () => {
                  router.pushUrl({
                    url: 'pages/ProductDetailPage',
                    params: { productId: rec.product.productId }
                  });
                }
              })
            }, (rec: RecommendationItem) => rec.product.productId)
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
