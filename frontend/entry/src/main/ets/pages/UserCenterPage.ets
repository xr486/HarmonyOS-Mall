import { UserService } from '../services/user/UserService';
import { User } from '../common/models';
import { AuthManager } from '../services/auth/AuthManager';
import { Logger } from '../common/utils/logger/Logger';
import { StorageUtil } from '../common/utils/storage/StorageUtil';
import { StorageKeys } from '../common/constants/StorageKeys';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

const TAG = 'UserCenterPage';

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
      const storage = StorageUtil.getInstance();
      const phone = await storage.getString(StorageKeys.USER_PHONE, '');
      if (phone) {
        const service: UserService = UserService.getInstance();
        const result: User | null = await service.getUserByPhone(phone);
        this.user = result;
      } else {
        this.user = null;
      }
    } catch (e) {
      this.user = null;
    }
    this.isLoading = false;
  }

  async logout(): Promise<void> {
    try {
      const auth = AuthManager.getInstance();
      await auth.signOut();
      this.user = null;
      promptAction.showToast({ message: '已退出登录' });
    } catch (e) {
      Logger.error(TAG, 'Logout failed: %{public}s', JSON.stringify(e));
    }
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
            .onClick(() => {
              if (this.user) {
                router.pushUrl({ url: 'pages/UserInfo' });
              } else {
                router.pushUrl({ url: 'pages/Login' });
              }
            })
            Column() {
              Text(this.user ? this.user.nickname : '未登录')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
              Text(this.user ? this.user.phone : '点击登录')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .margin({ left: 16 })
            .alignItems(HorizontalAlign.Start)
            .onClick(() => {
              if (this.user) {
                router.pushUrl({ url: 'pages/UserInfo' });
              } else {
                router.pushUrl({ url: 'pages/Login' });
              }
            })
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 10 })

          Column() {
            MenuItem({ icon: '📦', title: '我的订单', desc: '查看全部订单' })
              .onClick(() => {
                router.pushUrl({ url: 'pages/OrderListPage' });
              })
            Divider().margin({ left: 50 })
            MenuItem({ icon: '📍', title: '收货地址', desc: '管理收货地址' })
              .onClick(() => {
                router.pushUrl({ url: 'pages/AddressList' });
              })
            Divider().margin({ left: 50 })
            MenuItem({ icon: '❤️', title: '我的收藏', desc: '收藏的商品' })
              .onClick(() => {
                router.pushUrl({ url: 'pages/FavoritePage' });
              })
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
            .onClick(() => {
              this.logout();
            })
        }
        .padding(12)
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
  }
}

@Component
struct MenuItem {
  @Prop icon: string = '';
  @Prop title: string = '';
  @Prop desc: string = '';
  @BuilderParam onClick?: () => void;

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
          .fontColor('#999999')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('>')
        .fontSize(16)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .onClick(() => {
      if (this.onClick) {
        this.onClick();
      }
    })
  }
}
