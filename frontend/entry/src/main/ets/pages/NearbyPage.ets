import { LocationManager, GeoCoder, NearbyService } from '../common/utils';
import type { LocationInfo, AddressComponent, NearbyProduct } from '../common/utils';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct NearbyPage {
  @State products: NearbyProduct[] = [];
  @State address: string = '正在定位...';
  @State isLoading: boolean = true;
  @State geoAddr: AddressComponent | null = null;

  aboutToAppear(): void {
    this.loadNearby();
  }

  async loadNearby(): Promise<void> {
    this.isLoading = true;
    try {
      const locMgr: LocationManager = LocationManager.getInstance();
      const geo: GeoCoder = GeoCoder.getInstance();
      const nearbySvc: NearbyService = NearbyService.getInstance();

      const location: LocationInfo = await locMgr.getCurrentLocation();
      const geoResult = await geo.reverseGeocode(location);
      this.geoAddr = geoResult.addressComponent;
      this.address = `${geoResult.addressComponent.city}${geoResult.addressComponent.district}`;

      const list: NearbyProduct[] = await nearbySvc.getNearbyProducts({
        latitude: location.latitude,
        longitude: location.longitude,
        radius: 50,
        limit: 20
      });

      this.products = nearbySvc.sortByDistance(list);
    } catch (e) {
      this.address = '定位失败';
      this.products = [];
    }
    this.isLoading = false;
  }

  onProductClick(product: NearbyProduct): void {
    router.pushUrl({
      url: 'pages/ProductDetailPage',
      params: { productId: product.productId }
    });
  }

  build() {
    Column() {
      Row() {
        Button() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(24).height(24).fillColor('#333333')
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => { router.back(); })

        Column() {
          Text('附近好物').fontSize(18).fontWeight(FontWeight.Medium)
          Text(this.address).fontSize(12).fontColor(this.geoAddr ? '#FF4D4F' : '#999')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(24).height(24).fillColor(Color.Transparent)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#FF4D4F')
          Text('正在搜索附近好物...').fontSize(14).fontColor('#999').margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.products.length === 0) {
        Column() {
          Text('附近暂无商品').fontSize(16).fontColor('#999')
          Text('试试扩大搜索范围').fontSize(13).fontColor('#CCC').margin({ top: 8 })
          Button('重新搜索')
            .margin({ top: 20 })
            .backgroundColor('#FF4D4F')
            .borderRadius(20)
            .onClick(() => { this.loadNearby(); })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.products, (item: NearbyProduct) => {
            ListItem() {
              Row() {
                Image(item.images)
                  .width(80).height(80)
                  .borderRadius(8)
                  .backgroundColor('#F5F5F5')
                  .objectFit(ImageFit.Cover)

                Column() {
                  Text(item.name)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')

                  Row() {
                    Text(`¥${item.price}`)
                      .fontSize(16)
                      .fontColor('#FF4D4F')
                      .fontWeight(FontWeight.Bold)

                    Blank()

                    Row() {
                      Text('📌').fontSize(11)
                      Text(item.distanceText)
                        .fontSize(11)
                        .fontColor('#FF4D4F')
                    }
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor('#FFF1F0')
                    .borderRadius(8)
                  }
                  .width('100%')
                  .margin({ top: 6 })
                  .alignItems(VerticalAlign.Center)
                }
                .layoutWeight(1)
                .height(80)
                .margin({ left: 12 })
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Color.White)
              .borderRadius(10)
              .onClick(() => { this.onProductClick(item); })
            }
          }, (item: NearbyProduct) => item.productId)
        }
        .layoutWeight(1)
        .padding(12)
        .scrollBar(BarState.Off)
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
  }
}
