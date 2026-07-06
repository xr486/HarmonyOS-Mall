import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import {
  PaymentMethodType,
  PaymentResultStatus,
  PAYMENT_CHANNELS,
  PaymentChannelInfo,
  PaymentResult,
  PayPageParams
} from '../common/models/PaymentTypes';
import { PaymentManager } from '../services/payment/PaymentManager';
import { Logger } from '../common/utils/logger/Logger';
import { OrderRefreshUtil } from '../common/utils/OrderRefreshUtil';

const TAG = 'PaymentPage';

@Entry
@Component
struct PaymentPage {
  @State orderId: string = '';
  @State orderNo: string = '';
  @State amount: number = 0;
  @State selectedMethod: PaymentMethodType = PaymentMethodType.ALIPAY;
  @State isPaying: boolean = false;
  @State showResult: boolean = false;
  @State payResult: PaymentResult | null = null;

  aboutToAppear() {
    const params: Object = router.getParams();
    if (params !== undefined) {
      const pageParams = params as PayPageParams;
      this.orderId = pageParams.orderId;
      this.orderNo = pageParams.orderNo;
      this.amount = pageParams.amount;
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        this.buildHeader();
        this.buildOrderInfo();
        this.buildChannelList();
        Blank();
        this.buildPayButton();
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f5f5f5')

      if (this.showResult && this.payResult !== null) {
        this.buildResultDialog();
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.startIcon'))
        .width(24)
        .height(24)
        .onClick(() => router.back())
      Text('收银台')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      Text('')
        .width(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }

  @Builder
  buildOrderInfo() {
    Column() {
      Text('支付金额')
        .fontSize(14)
        .fontColor('#999')
        .margin({ bottom: 8 })
      Text('¥' + this.amount.toFixed(2))
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ff4d4f')
      Text('订单号: ' + this.orderNo)
        .fontSize(12)
        .fontColor('#999')
        .margin({ top: 8 })
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildChannelList() {
    Column() {
      Text('选择支付方式')
        .fontSize(14)
        .fontColor('#666')
        .width('100%')
        .margin({ bottom: 12 })

      ForEach(PAYMENT_CHANNELS, (channel: PaymentChannelInfo) => {
        this.buildChannelItem(channel);
      }, (channel: PaymentChannelInfo) => channel.method)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
  }

  @Builder
  buildChannelItem(channel: PaymentChannelInfo) {
    Row() {
      Column() {
        Text(channel.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(channel.desc)
          .fontSize(12)
          .fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (!channel.enabled) {
        Text('暂不可用')
          .fontSize(12)
          .fontColor('#999')
      } else {
        if (this.selectedMethod === channel.method) {
          Text('✓')
            .fontSize(18)
            .fontColor('#1677ff')
        }
      }
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
    .borderRadius(8)
    .onClick(() => {
      if (channel.enabled) {
        this.selectedMethod = channel.method;
      }
    })
  }

  @Builder
  buildPayButton() {
    Button(this.isPaying ? '支付中...' : '确认支付 ¥' + this.amount.toFixed(2))
      .width('100%')
      .height(50)
      .fontSize(16)
      .backgroundColor(this.isPaying ? '#ccc' : '#1677ff')
      .fontColor(Color.White)
      .borderRadius(25)
      .margin(16)
      .enabled(!this.isPaying)
      .onClick(() => this.doPay())
  }

  @Builder
  buildResultDialog() {
    Column() {
      Column() {
        if (this.payResult !== null && this.payResult.status === PaymentResultStatus.SUCCESS) {
          Text('✓')
            .fontSize(48)
            .fontColor('#52c41a')
            .margin({ bottom: 16 })
          Text('支付成功')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })
          if (this.payResult.transactionNo !== undefined) {
            Text('交易号: ' + this.payResult.transactionNo)
              .fontSize(12)
              .fontColor('#999')
          }
        } else if (this.payResult !== null && this.payResult.status === PaymentResultStatus.PROCESSING) {
          LoadingProgress()
            .width(48)
            .height(48)
            .color('#1677ff')
            .margin({ bottom: 16 })
          Text('支付处理中')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })
          Text(this.getErrorMsg())
            .fontSize(14)
            .fontColor('#999')
        } else {
          Text('✕')
            .fontSize(48)
            .fontColor('#ff4d4f')
            .margin({ bottom: 16 })
          Text('支付失败')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })
          Text(this.getFailedMsg())
            .fontSize(14)
            .fontColor('#999')
        }

        if (this.payResult !== null && this.payResult.status === PaymentResultStatus.FAILED) {
          Button('重试')
            .width('100%')
            .height(44)
            .fontSize(16)
            .backgroundColor('#1677ff')
            .fontColor(Color.White)
            .borderRadius(22)
            .margin({ top: 24 })
            .onClick(() => {
              this.showResult = false;
              this.payResult = null;
            })
        }

        Button(this.payResult !== null && this.payResult.status === PaymentResultStatus.SUCCESS ? '完成' : '返回')
          .width('100%')
          .height(44)
          .fontSize(16)
          .backgroundColor(this.payResult !== null && this.payResult.status === PaymentResultStatus.SUCCESS ? '#52c41a' : '#f5f5f5')
          .fontColor(this.payResult !== null && this.payResult.status === PaymentResultStatus.SUCCESS ? Color.White : '#333')
          .borderRadius(22)
          .margin({ top: 12 })
          .onClick(() => {
            if (this.payResult !== null && this.payResult.status === PaymentResultStatus.SUCCESS) {
              OrderRefreshUtil.trigger();
            }
            router.back();
          })
      }
      .width('85%')
      .padding(24)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({ radius: 20, color: '#00000020' })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#00000050')
  }

  getFailedMsg(): string {
    if (this.payResult !== null && this.payResult.errorMsg !== undefined) {
      return this.payResult.errorMsg;
    }
    return '支付失败，请重试';
  }

  getErrorMsg(): string {
    if (this.payResult !== null && this.payResult.errorMsg !== undefined) {
      return this.payResult.errorMsg;
    }
    return '请等待支付结果...';
  }

  async doPay(): Promise<void> {
    if (this.isPaying) {
      return;
    }
    this.isPaying = true;
    try {
      const manager: PaymentManager = PaymentManager.getInstance();
      const result: PaymentResult = await manager.pay(this.orderId, this.selectedMethod);
      this.payResult = result;
      this.showResult = true;
      if (result.status === PaymentResultStatus.SUCCESS) {
        Logger.info(TAG, '支付成功: %{public}s', this.orderId);
      }
    } catch (e) {
      this.payResult = {
        paymentId: '',
        orderId: this.orderId,
        orderNo: this.orderNo,
        status: PaymentResultStatus.FAILED,
        errorCode: 'UNKNOWN',
        errorMsg: '支付异常，请重试'
      };
      this.showResult = true;
      Logger.error(TAG, '支付异常: %{public}s', JSON.stringify(e));
    }
    this.isPaying = false;
  }
}
