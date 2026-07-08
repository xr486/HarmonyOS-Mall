/**
 * 近期浏览卡片 - 2x4尺寸
 * 展示4个热销商品
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

  build() {
    Column() {
      Row() {
        Text('近期浏览')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 4 })

      Row() {
        ForEach(this.products, (item: ProductCardItem, index: number) => {
          Column() {
            Column()
              .width(50)
              .height(50)
              .backgroundColor(['#FFF0F0', '#F0F0FF', '#F0FFF0', '#FFF0FF'][index % 4])
              .borderRadius(8)

            Text(item.name)
              .fontSize(10)
              .fontColor('#333')
              .margin({ top: 4 })

            Text('¥' + item.price)
              .fontSize(11)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF4D4F')
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
      .padding({ left: 4, right: 4 })
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
