import { Product } from '../common/models';

@Component
export struct ProductCard {
  @Prop product: Product;
  onCardClick?: () => void;

  build() {
    Column() {
      Column() {
        Image(this.product.images && this.product.images.length > 0 ? this.product.images[0] : '')
          .width('100%')
          .height(160)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 8, topRight: 8 })
          .alt($r('app.media.app_icon'))

        Column() {
          Text(this.product.name)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Row({ space: 4 }) {
            Text(`¥${this.product.price}`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF4D4F')

            if (this.product.originalPrice && this.product.originalPrice > this.product.price) {
              Text(`¥${this.product.originalPrice}`)
                .fontSize(11)
                .fontColor('#999')
                .decoration({ type: TextDecorationType.LineThrough })
            }
          }
          .width('100%')
          .margin({ top: 4 })

          Text(`已售 ${this.product.salesCount}`)
            .fontSize(11)
            .fontColor('#999')
            .margin({ top: 2 })
        }
        .padding(8)
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(8)
    }
    .width('48%')
    .margin({ bottom: 8 })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick();
      }
    })
  }
}
