import { FavoriteService } from '../services/product/FavoriteService';
import { FavoriteItem } from '../common/models';
import router from '@ohos.router';

@Entry
@Component
struct FavoritePage {
  @State favorites: FavoriteItem[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadFavorites();
  }

  onPageShow(): void {
    this.loadFavorites();
  }

  async loadFavorites(): Promise<void> {
    this.isLoading = true;
    try {
      const service: FavoriteService = FavoriteService.getInstance();
      this.favorites = await service.getFavorites();
    } catch (e) {
      this.favorites = [];
    }
    this.isLoading = false;
  }

  goToDetail(productId: string): void {
    router.pushUrl({
      url: 'pages/ProductDetailPage',
      params: { productId: productId }
    });
  }

  @Builder
  NavBar() {
    Row() {
      Text('←')
        .fontSize(22)
        .fontColor('#333')
        .onClick(() => router.back())

      Text('我的收藏')
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
  EmptyView() {
    Column() {
      Text('暂无收藏')
        .fontSize(16)
        .fontColor('#999')
      Text('去逛逛发现好物吧')
        .fontSize(13)
        .fontColor('#CCC')
        .margin({ top: 8 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
  }

  @Builder
  FavoriteCard(item: FavoriteItem) {
    Row() {
      if (item.images && item.images.length > 0) {
        Image(item.images[0])
          .width(88)
          .height(88)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
          .alt($r('app.media.app_icon'))
      }

      Column() {
        Text(item.name)
          .fontSize(14)
          .fontColor('#333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Blank()
          .layoutWeight(1)

        Row() {
          Text('￥' + item.price)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF4D4F')

          Text('评分 ' + item.rating.toFixed(1))
            .fontSize(12)
            .fontColor('#999')
            .margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .height(88)
      .margin({ left: 10 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ bottom: 10 })
    .onClick(() => this.goToDetail(item.productId))
  }

  build() {
    Column() {
      this.NavBar()

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40)
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else if (this.favorites.length === 0) {
        this.EmptyView()
      } else {
        Scroll() {
          Column() {
            ForEach(this.favorites, (item: FavoriteItem) => {
              this.FavoriteCard(item)
            }, (item: FavoriteItem) => item.favoriteId)
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 12, bottom: 12 })
          .justifyContent(FlexAlign.Start)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
