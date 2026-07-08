/**
 * 购物车状态卡片 - 2x2尺寸
 */
@Entry
@Component
struct CartStatusCard {
  @State count: number = 3;
  @State total: number = 4798;

  build() {
    Column() {
      Text('购物车')
        .fontSize(13)
        .fontColor('#666')
        .margin({ bottom: 8 })

      Text('' + this.count)
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FF4D4F')

      Text('件商品')
        .fontSize(12)
        .fontColor('#999')
        .margin({ top: 4 })

      Text('合计 ¥' + this.total)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        params: { url: 'pages/Index' }
      });
    })
  }
}
