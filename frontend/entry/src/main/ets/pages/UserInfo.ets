import { UserService } from '../services/user/UserService';
import { User } from '../common/models';
import { Logger } from '../common/utils/logger/Logger';
import { StorageUtil } from '../common/utils/storage/StorageUtil';
import { StorageKeys } from '../common/constants/StorageKeys';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

const TAG = 'UserInfo';

@Entry
@Component
struct UserInfo {
  @State user: User | null = null;
  @State nickname: string = '';
  @State avatarUrl: string = '';
  @State isLoading: boolean = false;

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
        if (result) {
          this.nickname = result.nickname || '';
        }
      }
    } catch (e) {
      Logger.error(TAG, 'Load user failed: %{public}s', JSON.stringify(e));
    }
    this.isLoading = false;
  }

  selectAvatar(): void {
    promptAction.showToast({ message: '头像选择功能开发中' });
  }

  async saveUserInfo(): Promise<void> {
    if (!this.nickname.trim()) {
      promptAction.showToast({ message: '请输入昵称' });
      return;
    }

    this.isLoading = true;
    try {
      if (this.user) {
        this.user.nickname = this.nickname;
        const service: UserService = UserService.getInstance();
        await service.updateUser(this.user);
        promptAction.showToast({ message: '保存成功' });
        router.back();
      }
    } catch (e) {
      Logger.error(TAG, 'Save user info failed: %{public}s', JSON.stringify(e));
      promptAction.showToast({ message: '保存失败' });
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      this.BuildHeader()
      this.BuildContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  BuildHeader() {
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

      Text('个人信息')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Button('保存')
        .type(ButtonType.Normal)
        .fontSize(14)
        .backgroundColor(Color.Transparent)
        .fontColor('#FF4D4F')
        .enabled(!this.isLoading)
        .onClick(() => {
          this.saveUserInfo();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
  }

  @Builder
  BuildContent() {
    Column() {
      Column() {
        this.BuildAvatarItem()
        Divider().margin({ left: 16 })
        this.BuildNicknameItem()
        Divider().margin({ left: 16 })
        this.BuildPhoneItem()
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
    .padding(12)
  }

  @Builder
  BuildAvatarItem() {
    Row() {
      Text('头像')
        .fontSize(15)
        .fontColor('#333333')

      Blank()

      Circle()
        .width(56)
        .height(56)
        .fill('#FF4D4F')
        .margin({ right: 8 })
        .onClick(() => {
          this.selectAvatar();
        })

      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(16)
        .height(16)
        .fillColor('#CCCCCC')
    }
    .width('100%')
    .padding(16)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  BuildNicknameItem() {
    Row() {
      Text('昵称')
        .fontSize(15)
        .fontColor('#333333')

      Blank()

      TextInput({ text: this.nickname, placeholder: '请输入昵称' })
        .fontSize(15)
        .textAlign(TextAlign.End)
        .width(200)
        .backgroundColor(Color.Transparent)
        .onChange((value: string) => {
          this.nickname = value;
        })
    }
    .width('100%')
    .padding(16)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  BuildPhoneItem() {
    Row() {
      Text('手机号')
        .fontSize(15)
        .fontColor('#333333')

      Blank()

      Text(this.user ? this.maskPhone(this.user.phone) : '')
        .fontSize(15)
        .fontColor('#999999')
    }
    .width('100%')
    .padding(16)
    .alignItems(VerticalAlign.Center)
  }

  maskPhone(phone: string): string {
    if (!phone || phone.length < 11) {
      return phone;
    }
    return phone.slice(0, 3) + '****' + phone.slice(7);
  }
}
