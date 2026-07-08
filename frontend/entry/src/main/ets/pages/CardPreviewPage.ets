import router from '@ohos.router';

/**
 * 服务卡片预览页
 * 展示两种卡片样式和使用说明
 */
@Entry
@Component
struct CardPreviewPage {

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('←')
          .fontSize(22)
          .fontColor('#333')
          .onClick(() => router.back())
        Text('服务卡片')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank()
          .width(30)
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      Scroll() {
        Column() {
          // 说明提示
          Column() {
            Text('📌 使用说明')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .margin({ bottom: 10 })
              .width('100%')
            Text('长按 App 图标 → 点击「服务卡片」 → 选择以下卡片添加到桌面')
              .fontSize(13)
              .fontColor('#666')
              .lineHeight(20)
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFF8E1')
          .borderRadius(10)
          .margin({ bottom: 16 })

          // 卡片1：常用商品 (2x4)
          Text('常用商品卡片 (2x4)')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
            .width('100%')
            .margin({ bottom: 10 })

          Column() {
            Row() {
              Text('精选好物').fontSize(12).fontWeight(FontWeight.Bold).fontColor('#333')
            }
            .width('100%')
            .margin({ bottom: 8 })

            Row() {
              ForEach(['手机', '耳机', '平板', '手表'], (name: string, idx: number) => {
                Column() {
                  Column()
                    .width(50)
                    .height(50)
                    .backgroundColor('#F0F0F0')
                    .borderRadius(8)

                  Text(name)
                    .fontSize(10)
                    .fontColor('#333')
                    .margin({ top: 4 })

                  Text('¥' + (999 + idx * 500))
                    .fontSize(11)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FF4D4F')
                }
                .width('25%')
                .alignItems(HorizontalAlign.Center)
              }, (n: string) => n)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceEvenly)

            Text('点击商品跳转详情页')
              .fontSize(10)
              .fontColor('#999')
              .margin({ top: 8 })
          }
          .width(280)
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .shadow({ radius: 8, color: '#10000000', offsetY: 2 })
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: 24 })

          // 卡片2：购物车状态 (2x2)
          Text('购物车状态卡片 (2x2)')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
            .width('100%')
            .margin({ bottom: 10 })

          Column() {
            Text('购物车')
              .fontSize(12)
              .fontColor('#666')
              .margin({ bottom: 8 })

            Text('2')
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF4D4F')

            Text('件商品')
              .fontSize(11)
              .fontColor('#999')
              .margin({ top: 2 })

            Text('合计 ¥1998')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .margin({ top: 6 })

            Text('点击跳转购物车')
              .fontSize(10)
              .fontColor('#999')
              .margin({ top: 6 })
          }
          .width(160)
          .height(160)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .shadow({ radius: 8, color: '#10000000', offsetY: 2 })

          // 底部功能说明
          Column() {
            Text('🔄 自动刷新')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
              .margin({ bottom: 4 })
              .width('100%')
            Text('卡片每小时自动更新数据，购物车和商品价格变化会即时同步到桌面')
              .fontSize(12)
              .fontColor('#666')
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(10)
          .margin({ top: 24 })
        }
        .padding(16)
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
