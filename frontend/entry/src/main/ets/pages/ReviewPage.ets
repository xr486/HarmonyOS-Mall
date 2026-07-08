import { ReviewService } from '../services/product/ReviewService';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface StarItem {
  label: string;
  value: number;
}

@Entry
@Component
struct ReviewPage {
  @State rating: number = 5;
  @State content: string = '';
  @State submitting: boolean = false;
  private productId: string = '';
  private productName: string = '';
  private orderId: string = '';
  private orderItemId: string = '';
  
  private stars: StarItem[] = [
    { label: '很差', value: 1 },
    { label: '较差', value: 2 },
    { label: '一般', value: 3 },
    { label: '满意', value: 4 },
    { label: '非常满意', value: 5 }
  ];

  aboutToAppear(): void {
    const params: Record<string, Object> = router.getParams() as Record<string, Object>;
    if (params) {
      this.productId = (params['productId'] as string) ?? '';
      this.productName = (params['productName'] as string) ?? '商品';
      this.orderId = (params['orderId'] as string) ?? '';
      this.orderItemId = (params['orderItemId'] as string) ?? '';
    }
  }

  async submitReview(): Promise<void> {
    if (this.content.trim().length === 0) {
      promptAction.showToast({ message: '请输入评价内容' });
      return;
    }
    if (this.submitting) return;
    this.submitting = true;

    try {
      const service: ReviewService = ReviewService.getInstance();
      const success: boolean = await service.createReview(
        this.productId, this.rating, this.content.trim(), this.orderId, this.orderItemId
      );
      if (success) {
        promptAction.showToast({ message: '评价成功' });
        router.back();
      } else {
        promptAction.showToast({ message: '评价失败，请重试' });
      }
    } catch (e) {
      promptAction.showToast({ message: '网络异常，请重试' });
    }
    this.submitting = false;
  }

  @Builder
  NavBar() {
    Row() {
      Text('←')
        .fontSize(22)
        .fontColor('#333')
        .onClick(() => router.back())

      Text('发布评价')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text('提交')
        .fontSize(15)
        .fontColor(this.content.trim().length > 0 ? '#FF4D4F' : '#CCC')
        .onClick(() => this.submitReview())
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }

  @Builder
  StarRating() {
    Column() {
      Text(`评分：${this.rating} 分`)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
        .margin({ bottom: 12 })

      Row() {
        ForEach(this.stars, (item: StarItem, index: number) => {
          Column() {
            Text(index < this.rating ? '⭐' : '☆')
              .fontSize(36)
              .onClick(() => { this.rating = item.value; })
            Text(item.label)
              .fontSize(11)
              .fontColor(index < this.rating ? '#FF9500' : '#CCC')
              .margin({ top: 4 })
          }
          .margin({ left: index > 0 ? 10 : 0 })
        }, (item: StarItem) => item.label)
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ bottom: 10 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ContentInput() {
    Column() {
      Text('评价内容')
        .fontSize(14)
        .fontColor('#333')
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 10 })
        .width('100%')

      TextArea({ text: this.content, placeholder: '说说你的使用感受吧～' })
        .fontSize(15)
        .height(150)
        .width('100%')
        .backgroundColor('#F9F9F9')
        .borderRadius(8)
        .padding(12)
        .onChange((value: string) => {
          this.content = value;
        })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  build() {
    Column() {
      this.NavBar()

      Scroll() {
        Column() {
          Column() {
            Text(this.productName)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .width('100%')
              .margin({ bottom: 4 })
            if (this.orderId.length > 0) {
              Text('订单号：' + this.orderId)
                .fontSize(13)
                .fontColor('#999')
                .width('100%')
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(10)
          .margin({ bottom: 10 })

          this.StarRating()
          this.ContentInput()
        }
        .padding({ left: 12, right: 12, top: 12, bottom: 12 })
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
