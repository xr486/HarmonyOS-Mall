/**
 * 近期浏览卡片 - 2x4尺寸
 * 展示4个热销商品，每个商品用图标+名称+价格清晰呈现
 */
@Entry
@Component
struct FrequentProductCard {
  @State products: ProductCardItem[] = [
    { id: '1', name: '手机', price: 2999 },
    { id: '2', name: '耳机', price: 899 },
    { id: '3', name: '平板', price: 3499 },
    { id: '4', name: '手表', price: 1999 }
  ];

  private readonly bgColors: string[] = ['#FFF0F0', '#F0F0FF', '#F0FFF0', '#FFF0FF'];

  build() {
    Column() {
      Row() {
        Text('近期浏览')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
        Blank()
          .layoutWeight(1)
        Text('4件')
          .fontSize(11)
          .fontColor('#999')
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 10, bottom: 6 })

      Row() {
        ForEach(this.products, (item: ProductCardItem, index: number) => {
          Column() {
            // 商品图标区：用首字+边框+背景色，视觉上更明确
            Column() {
              Text(item.name.substring(0, 1))
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF4D4F')
            }
            .width(52)
            .height(52)
            .backgroundColor(this.bgColors[index % 4])
            .borderRadius(10)
            .border({ width: 1, color: '#E8E8E8' })
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Text(item.name)
              .fontSize(11)
              .fontColor('#333')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 6 })
              .width(54)
              .textAlign(TextAlign.Center)

            Text('¥' + item.price)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF4D4F')
              .margin({ top: 2 })
          }
          .width('25%')
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            postCardAction(this, {
              action: 'router',
              abilityName: 'EntryAbility',
              params: { url: 'pages/ProductDetailPage', productId: item.id }
            });
          })
        }, (item: ProductCardItem, index: number) => item.id + index)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .padding({ left: 8, right: 8, bottom: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}

interface ProductCardItem {
  id: string;
  name: string;
  price: number;
}
