import { AddressService } from '../services/user/AddressService';
import { Address } from '../common/models';
import { Logger } from '../common/utils/logger/Logger';
import { StorageUtil } from '../common/utils/storage/StorageUtil';
import { StorageKeys } from '../common/constants/StorageKeys';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

const TAG = 'AddressEdit';

@Entry
@Component
struct AddressEdit {
  @State address: Address | null = null;
  @State name: string = '';
  @State phone: string = '';
  @State province: string = '';
  @State city: string = '';
  @State district: string = '';
  @State detail: string = '';
  @State isDefault: boolean = false;
  @State isLoading: boolean = false;
  @State isEdit: boolean = false;
  @State userId: string = '';
  @State regionText: string = '';

  aboutToAppear(): void {
    this.loadUserId();
    const params = router.getParams() as Record<string, string>;
    if (params && params['address']) {
      this.address = JSON.parse(params['address']) as Address;
      this.isEdit = true;
      this.initData();
    }
  }

  initData(): void {
    if (this.address) {
      this.name = this.address.name;
      this.phone = this.address.phone;
      this.province = this.address.province;
      this.city = this.address.city;
      this.district = this.address.district;
      this.detail = this.address.detail;
      this.isDefault = this.address.isDefault;
      this.regionText = this.province + this.city + this.district;
    }
  }

  async loadUserId(): Promise<void> {
    const storage = StorageUtil.getInstance();
    const phone = await storage.getString(StorageKeys.USER_PHONE, '');
    this.userId = phone || 'unknown';
  }

  selectRegion(): void {
    promptAction.showToast({ message: '省市区选择功能开发中' });
  }

  onNameChange(value: string): void {
    this.name = value;
  }

  onPhoneChange(value: string): void {
    this.phone = value;
  }

  onDetailChange(value: string): void {
    this.detail = value;
  }

  onDefaultChange(isOn: boolean): void {
    this.isDefault = isOn;
  }

  async saveAddress(): Promise<void> {
    if (!this.name.trim()) {
      promptAction.showToast({ message: '请输入收货人姓名' });
      return;
    }
    if (!this.phone.trim()) {
      promptAction.showToast({ message: '请输入手机号' });
      return;
    }
    if (!this.province || !this.city || !this.district) {
      promptAction.showToast({ message: '请选择省市区' });
      return;
    }
    if (!this.detail.trim()) {
      promptAction.showToast({ message: '请输入详细地址' });
      return;
    }

    this.isLoading = true;
    try {
      const service: AddressService = AddressService.getInstance();

      if (this.isEdit && this.address) {
        this.address.name = this.name;
        this.address.phone = this.phone;
        this.address.province = this.province;
        this.address.city = this.city;
        this.address.district = this.district;
        this.address.detail = this.detail;
        this.address.isDefault = this.isDefault;
        this.address.updatedAt = Date.now();
        await service.updateAddress(this.address);
        promptAction.showToast({ message: '修改成功' });
      } else {
        const newAddress: Address = {
          addressId: this.generateId(),
          userId: this.userId,
          name: this.name,
          phone: this.phone,
          province: this.province,
          city: this.city,
          district: this.district,
          detail: this.detail,
          isDefault: this.isDefault,
          createdAt: Date.now(),
          updatedAt: Date.now()
        };
        await service.addAddress(newAddress);
        promptAction.showToast({ message: '添加成功' });
      }
      router.back();
    } catch (e) {
      Logger.error(TAG, 'Save address failed: %{public}s', JSON.stringify(e));
      promptAction.showToast({ message: '保存失败' });
    }
    this.isLoading = false;
  }

  generateId(): string {
    return 'addr_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
  }

  build() {
    Column() {
      this.BuildHeader()
      this.BuildContent()
      this.BuildSaveButton()
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

      Text(this.isEdit ? '编辑地址' : '新增地址')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Button()
      .type(ButtonType.Normal)
      .backgroundColor(Color.Transparent)
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
        this.BuildNameItem()
        Divider().margin({ left: 16 })
        this.BuildPhoneItem()
        Divider().margin({ left: 16 })
        this.BuildRegionItem()
        Divider().margin({ left: 16 })
        this.BuildDetailItem()
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 12 })

      Column() {
        Row() {
          Text('设为默认地址')
            .fontSize(15)
            .fontColor('#333333')
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.isDefault })
            .selectedColor('#FF4D4F')
            .onChange((isOn: boolean) => {
              this.isDefault = isOn;
            })
        }
        .width('100%')
        .padding(16)
        .alignItems(VerticalAlign.Center)
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
  BuildNameItem() {
    Row() {
      Text('收货人')
        .fontSize(15)
        .fontColor('#333333')
        .width(80)

      TextInput({ text: this.name, placeholder: '请输入收货人姓名' })
        .fontSize(15)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
        .backgroundColor(Color.Transparent)
        .onChange((value: string) => {
          this.name = value;
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
        .width(80)

      TextInput({ text: this.phone, placeholder: '请输入手机号' })
        .fontSize(15)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
        .backgroundColor(Color.Transparent)
        .type(InputType.Number)
        .onChange((value: string) => {
          this.phone = value;
        })
    }
    .width('100%')
    .padding(16)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  BuildDetailItem() {
    Row() {
      Text('详细地址')
        .fontSize(15)
        .fontColor('#333333')
        .width(80)

      TextInput({ text: this.detail, placeholder: '请输入详细地址' })
        .fontSize(15)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
        .backgroundColor(Color.Transparent)
        .onChange((value: string) => {
          this.detail = value;
        })
    }
    .width('100%')
    .padding(16)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  BuildRegionItem() {
    Row() {
      Text('所在地区')
        .fontSize(15)
        .fontColor('#333333')
        .width(80)

      Text(this.regionText ? this.regionText : '请选择省市区')
        .fontSize(15)
        .fontColor(this.regionText ? '#333333' : '#999999')
        .layoutWeight(1)
        .textAlign(TextAlign.End)

      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(16)
        .height(16)
        .fillColor('#CCCCCC')
    }
    .width('100%')
    .padding(16)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.selectRegion();
    })
  }

  @Builder
  BuildSaveButton() {
    Button(this.isEdit ? '保存' : '添加')
      .width('100%')
      .height(48)
      .borderRadius(24)
      .backgroundColor('#FF4D4F')
      .enabled(!this.isLoading)
      .margin(16)
      .onClick(() => {
        this.saveAddress();
      })
  }
}
