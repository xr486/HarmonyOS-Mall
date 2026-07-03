import { AuthManager } from '../services/auth/AuthManager';
import { Logger } from '../common/utils/logger/Logger';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

const TAG = 'Register';

@Entry
@Component
struct Register {
  @State phone: string = '';
  @State verifyCode: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;
  @State countdown: number = 0;
  @State isAgreed: boolean = false;

  private timer: number = -1;

  aboutToDisappear(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  async sendVerifyCode(): Promise<void> {
    if (!this.phone) {
      promptAction.showToast({ message: '请输入手机号' });
      return;
    }

    this.isLoading = true;
    try {
      const auth: AuthManager = AuthManager.getInstance();
      const result: Object | null = await auth.requestVerifyCode(this.phone);

      if (result) {
        promptAction.showToast({ message: '验证码已发送（开发模式：123456）' });
        this.startCountdown();
      } else {
        promptAction.showToast({ message: '发送验证码失败，请检查网络' });
        Logger.error(TAG, 'Send verify code returned null');
      }
    } catch (e) {
      Logger.error(TAG, 'Send verify code failed: %{public}s', JSON.stringify(e));
      promptAction.showToast({ message: '发送失败' });
    }
    this.isLoading = false;
  }

  startCountdown(): void {
    this.countdown = 60;
    this.timer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(this.timer);
      }
    }, 1000);
  }

  async register(): Promise<void> {
    if (!this.phone || !this.verifyCode || !this.password || !this.confirmPassword) {
      promptAction.showToast({ message: '请填写完整信息' });
      return;
    }

    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: '两次密码不一致' });
      return;
    }

    if (this.password.length < 6) {
      promptAction.showToast({ message: '密码长度至少6位' });
      return;
    }

    if (!this.isAgreed) {
      promptAction.showToast({ message: '请同意用户协议和隐私政策' });
      return;
    }

    this.isLoading = true;
    try {
      const auth: AuthManager = AuthManager.getInstance();
      const result = await auth.register(this.phone, this.password, this.verifyCode);
      if (result) {
        promptAction.showToast({ message: '注册成功' });
        router.back();
      } else {
        promptAction.showToast({ message: '注册失败，手机号可能已注册' });
        Logger.error(TAG, 'register returned null');
      }
    } catch (e) {
      Logger.error(TAG, 'Register failed: %{public}s', JSON.stringify(e));
      promptAction.showToast({ message: '注册失败' });
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Button() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(24)
            .height(24)
            .fillColor('#333333')
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16 })
      .justifyContent(FlexAlign.Start)

      Scroll() {
        Column() {
          Text('创建账号')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .margin({ top: 20, bottom: 8 })

          Text('加入鸿蒙商城，开启购物之旅')
            .fontSize(14)
            .fontColor('#999999')
            .width('100%')
            .margin({ bottom: 32 })

          // 手机号
          TextInput({ text: this.phone, placeholder: '请输入手机号' })
            .type(InputType.Number)
            .maxLength(11)
            .width('100%')
            .height(48)
            .borderRadius(8)
            .border({ width: 1, color: '#E5E5E5' })
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => { this.phone = value; })
            .margin({ bottom: 16 })

          // 验证码
          Row() {
            TextInput({ text: this.verifyCode, placeholder: '请输入验证码' })
              .type(InputType.Number)
              .maxLength(6)
              .layoutWeight(1)
              .onChange((value: string) => { this.verifyCode = value; })

            Button(this.countdown > 0 ? this.countdown + 's后重发' : '获取验证码')
              .fontSize(14)
              .height(44)
              .backgroundColor(this.countdown > 0 ? '#E5E5E5' : '#FF4D4F')
              .fontColor(this.countdown > 0 ? '#999999' : Color.White)
              .enabled(this.countdown === 0 && !this.isLoading)
              .onClick(() => { this.sendVerifyCode(); })
          }
          .width('100%')
          .height(48)
          .borderRadius(8)
          .border({ width: 1, color: '#E5E5E5' })
          .padding({ left: 16, right: 8 })
          .margin({ bottom: 16 })

          // 密码
          TextInput({ text: this.password, placeholder: '请输入密码（至少6位）' })
            .type(InputType.Password)
            .width('100%')
            .height(48)
            .borderRadius(8)
            .border({ width: 1, color: '#E5E5E5' })
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => { this.password = value; })
            .margin({ bottom: 16 })

          // 确认密码
          TextInput({ text: this.confirmPassword, placeholder: '请确认密码' })
            .type(InputType.Password)
            .width('100%')
            .height(48)
            .borderRadius(8)
            .border({ width: 1, color: '#E5E5E5' })
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => { this.confirmPassword = value; })
            .margin({ bottom: 24 })

          // 协议勾选
          Row() {
            Checkbox()
              .select(this.isAgreed)
              .selectedColor('#FF4D4F')
              .onChange((value: boolean) => { this.isAgreed = value; })

            Text('我已阅读并同意')
              .fontSize(12)
              .fontColor('#999999')

            Text('《用户协议》')
              .fontSize(12)
              .fontColor('#FF4D4F')

            Text('和')
              .fontSize(12)
              .fontColor('#999999')

            Text('《隐私政策》')
              .fontSize(12)
              .fontColor('#FF4D4F')
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .margin({ bottom: 32 })

          // 注册按钮
          Button('注册')
            .width('100%')
            .height(48)
            .borderRadius(24)
            .backgroundColor('#FF4D4F')
            .enabled(!this.isLoading)
            .onClick(() => { this.register(); })
            .margin({ bottom: 24 })

          // 登录入口
          Row() {
            Text('已有账号？')
              .fontSize(14)
              .fontColor('#666666')

            Button('立即登录')
              .type(ButtonType.Normal)
              .fontSize(14)
              .backgroundColor(Color.Transparent)
              .fontColor('#FF4D4F')
              .onClick(() => {
                router.replaceUrl({ url: 'pages/Login' });
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .padding(24)
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
