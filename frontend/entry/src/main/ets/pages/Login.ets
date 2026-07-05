import { AuthManager } from '../services/auth/AuthManager';
import { Logger } from '../common/utils/logger/Logger';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

const TAG = 'Login';

@Entry
@Component
struct Login {
  @State phone: string = '';
  @State password: string = '';
  @State verifyCode: string = '';
  @State isLoading: boolean = false;
  @State countdown: number = 0;
  @State currentTab: number = 0; // 0=密码登录, 1=验证码登录

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
        promptAction.showToast({ message: '发送失败，请检查网络' });
      }
    } catch (e) {
      Logger.error(TAG, 'sendCode error: %{public}s', JSON.stringify(e));
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

  async loginByPassword(): Promise<void> {
    if (!this.phone) {
      promptAction.showToast({ message: '请输入手机号' });
      return;
    }
    if (!this.password) {
      promptAction.showToast({ message: '请输入密码' });
      return;
    }
    this.isLoading = true;
    try {
      const auth: AuthManager = AuthManager.getInstance();
      const result = await auth.signInByPassword(this.phone, this.password);
      if (result) {
        promptAction.showToast({ message: '登录成功' });
        router.back();
      } else {
        promptAction.showToast({ message: '账号或密码错误' });
      }
    } catch (e) {
      Logger.error(TAG, 'login error: %{public}s', JSON.stringify(e));
      promptAction.showToast({ message: '登录失败' });
    }
    this.isLoading = false;
  }

  async loginByCode(): Promise<void> {
    if (!this.phone) {
      promptAction.showToast({ message: '请输入手机号' });
      return;
    }
    if (!this.verifyCode) {
      promptAction.showToast({ message: '请输入验证码' });
      return;
    }
    this.isLoading = true;
    try {
      const auth: AuthManager = AuthManager.getInstance();
      const result = await auth.signInByCode(this.phone, this.verifyCode);
      if (result) {
        promptAction.showToast({ message: '登录成功' });
        router.back();
      } else {
        promptAction.showToast({ message: '验证码错误或登录失败' });
      }
    } catch (e) {
      Logger.error(TAG, 'login error: %{public}s', JSON.stringify(e));
      promptAction.showToast({ message: '登录失败' });
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
        Text('登录')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 8 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16 })
      .justifyContent(FlexAlign.Start)

      Scroll() {
        Column() {
          // 欢迎语
          Text('欢迎回来')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .margin({ top: 20, bottom: 8 })

          Text('登录您的账号')
            .fontSize(14)
            .fontColor('#999999')
            .width('100%')
            .margin({ bottom: 32 })

          // Tab 切换
          Row() {
            Column() {
              Text('密码登录')
                .fontSize(16)
                .fontWeight(this.currentTab === 0 ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.currentTab === 0 ? '#FF4D4F' : '#999999')
              Divider()
                .width(24)
                .height(2)
                .color(this.currentTab === 0 ? '#FF4D4F' : Color.Transparent)
                .margin({ top: 6 })
            }
            .onClick(() => { this.currentTab = 0; })

            Column() {
              Text('验证码登录')
                .fontSize(16)
                .fontWeight(this.currentTab === 1 ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.currentTab === 1 ? '#FF4D4F' : '#999999')
                .margin({ left: 32 })
              Divider()
                .width(24)
                .height(2)
                .color(this.currentTab === 1 ? '#FF4D4F' : Color.Transparent)
                .margin({ top: 6, left: 32 })
            }
            .onClick(() => { this.currentTab = 1; })
          }
          .width('100%')
          .margin({ bottom: 24 })

          // 手机号输入
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

          if (this.currentTab === 0) {
            // 密码登录
            TextInput({ text: this.password, placeholder: '请输入密码' })
              .type(InputType.Password)
              .width('100%')
              .height(48)
              .borderRadius(8)
              .border({ width: 1, color: '#E5E5E5' })
              .padding({ left: 16, right: 16 })
              .onChange((value: string) => { this.password = value; })
              .margin({ bottom: 24 })

            Button('登录')
              .width('100%')
              .height(48)
              .borderRadius(24)
              .backgroundColor('#FF4D4F')
              .enabled(!this.isLoading)
              .onClick(() => { this.loginByPassword(); })
          } else {
            // 验证码登录
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
            .margin({ bottom: 24 })

            Button('登录')
              .width('100%')
              .height(48)
              .borderRadius(24)
              .backgroundColor('#FF4D4F')
              .enabled(!this.isLoading)
              .onClick(() => { this.loginByCode(); })
          }

          // 注册入口
          Row() {
            Text('还没有账号？')
              .fontSize(14)
              .fontColor('#666666')

            Button('立即注册')
              .type(ButtonType.Normal)
              .fontSize(14)
              .backgroundColor(Color.Transparent)
              .fontColor('#FF4D4F')
              .onClick(() => {
                router.replaceUrl({ url: 'pages/Register' });
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 32 })
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
