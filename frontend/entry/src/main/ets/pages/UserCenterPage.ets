import { UserService } from '../services/user/UserService';
import { User } from '../common/models';
import router from '@ohos.router';

@Entry
@Component
struct UserCenterPage {
  @State user: User | null = null;
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadUser();
  }

  async loadUser(): Promise<void> {
    this.isLoading = true;
    try {
      const service: UserService = UserService.getInstance();
      const result: User | null = await service.getUserById('default_user');
      this.user = result;
    } catch (e) {
      this.user = null;
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      Row() {
        Text('我的')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)

      Scroll() {
        Column() {
          Row() {
            Column() {
              Circle()
                .width(64)
                .height(64)
                .fill('#FF4D4F')
            }
            Column() {
              Text(this.user ? this.user.nickname : '未登录')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
              Text(this.user ? this.user.phone : '点击登录')
                .fontSize(14)
                .fontColor('#999')
                .margin({ top: 4 })
            }
            .margin({ left: 16 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 10 })

          Column() {
            MenuItem({ icon: '📦', title: '我的订单', desc: '查看全部订单' })
            Divider().margin({ left: 50 })
            MenuItem({ icon: '📍', title: '收货地址', desc: '管理收货地址' })
            Divider().margin({ left: 50 })
            MenuItem({ icon: '❤️', title: '我的收藏', desc: '收藏的商品' })
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 10 })

          Column() {
            MenuItem({ icon: '⚙️', title: '设置', desc: '账号与安全' })
            Divider().margin({ left: 50 })
            MenuItem({ icon: '❓', title: '帮助中心', desc: '常见问题' })
            Divider().margin({ left: 50 })
            MenuItem({ icon: '💬', title: '意见反馈', desc: '告诉我们您的想法' })
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)

          Button('退出登录')
            .fontSize(14)
            .backgroundColor('#FFF1F0')
            .fontColor('#FF4D4F')
            .width('100%')
            .height(44)
            .borderRadius(22)
            .margin({ top: 30 })
        }
        .padding(12)
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct MenuItem {
  @Prop icon: string = '';
  @Prop title: string = '';
  @Prop desc: string = '';

  build() {
    Row() {
      Text(this.icon)
        .fontSize(20)
        .width(40)
        .textAlign(TextAlign.Center)

      Column() {
        Text(this.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
        Text(this.desc)
          .fontSize(12)
          .fontColor('#999')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('>')
        .fontSize(16)
        .fontColor('#CCC')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
  }
}
