import { Builder } from '@ohos.base';

interface RefreshHeaderParam {
  refreshing: boolean;
}

@Builder
export function RefreshHeaderBuilder(param: RefreshHeaderParam) {
  if (param.refreshing) {
    Row() {
      LoadingProgress()
        .width(20)
        .height(20)
        .color('#FF4D4F')
      Text('正在刷新推荐...')
        .fontSize(13)
        .fontColor('#999')
        .margin({ left: 8 })
    }
    .width('100%')
    .height(40)
    .justifyContent(FlexAlign.Center)
  }
}