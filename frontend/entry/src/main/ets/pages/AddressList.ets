import { AddressService } from '../services/user/AddressService';
import { Address } from '../common/models';
import { Logger } from '../common/utils/logger/Logger';
import { StorageUtil } from '../common/utils/storage/StorageUtil';
import { StorageKeys } from '../common/constants/StorageKeys';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

const TAG = 'AddressList';

@Entry
@Component
struct AddressList {
  @State addressList: Address[] = [];
  @State isLoading: boolean = false;
  @State userId: string = '';

  aboutToAppear(): void {
    this.loadUserId();
    this.loadAddresses();
  }

  async loadUserId(): Promise<void> {
    const storage = StorageUtil.getInstance();
    const phone = await storage.getString(StorageKeys.USER_PHONE, '');
    this.userId = phone || 'unknown';
  }

  async loadAddresses(): Promise<void> {
    this.isLoading = true;
    try {
      const service: AddressService = AddressService.getInstance();
      const addresses: Address[] = await service.getAddressesByUserId(this.userId);
      this.addressList = addresses;
    } catch (e) {
      Logger.error(TAG, 'Load addresses failed: %{public}s', JSON.stringify(e));
    }
    this.isLoading = false;
  }

  async setDefaultAddress(address: Address): Promise<void> {
    if (address.isDefault) {
      return;
    }

    this.isLoading = true;
    try {
      address.isDefault = true;
      address.updatedAt = Date.now();
      const service: AddressService = AddressService.getInstance();
      await service.updateAddress(address);
      await this.loadAddresses();
      promptAction.showToast({ message: '设置成功' });
    } catch (e) {
      Logger.error(TAG, 'Set default address failed: %{public}s', JSON.stringify(e));
      promptAction.showToast({ message: '设置失败' });
    }
    this.isLoading = false;
  }

  editAddress(address: Address): void {
    router.pushUrl({
      url: 'pages/AddressEdit',
      params: {
        'address': JSON.stringify(address)
      }
    });
  }

  async deleteAddress(addressId: string): Promise<void> {
    this.isLoading = true;
    try {
      const service: AddressService = AddressService.getInstance();
      await service.deleteAddress(addressId);
      await this.loadAddresses();
      promptAction.showToast({ message: '删除成功' });
    } catch (e) {
      Logger.error(TAG, 'Delete address failed: %{public}s', JSON.stringify(e));
      promptAction.showToast({ message: '删除失败' });
    }
    this.isLoading = false;
  }

  @State showDeleteConfirm: boolean = false;
  @State deletingAddressId: string = '';

  confirmDelete(address: Address): void {
    this.deletingAddressId = address.addressId;
    this.showDeleteConfirm = true;
  }

  cancelDelete(): void {
    this.showDeleteConfirm = false;
  }

  async doDelete(): Promise<void> {
    this.showDeleteConfirm = false;
    await this.deleteAddress(this.deletingAddressId);
  }

  addAddress(): void {
    router.pushUrl({ url: 'pages/AddressEdit' });
  }

  build() {
    Stack() {
    Column() {
      this.BuildHeader()
      this.BuildContent()
      this.BuildAddButton()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')

    if (this.showDeleteConfirm) {
      this.BuildDeleteConfirm()
    }
    }
  }

  @Builder
  BuildDeleteConfirm() {
    Column() {
      Column() {
        Text('提示')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 12 })

        Text('确定要删除该地址吗？')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ bottom: 24 })

        Row() {
          Button('取消')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .backgroundColor('#F0F0F0')
            .borderRadius(20)
            .onClick(() => {
              this.cancelDelete();
            })

          Button('确定')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .backgroundColor('#FF4D4F')
            .borderRadius(20)
            .margin({ left: 12 })
            .onClick(() => {
              this.doDelete();
            })
        }
        .width('100%')
      }
      .width('80%')
      .padding(24)
      .backgroundColor(Color.White)
      .borderRadius(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.4)')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.cancelDelete();
    })
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

      Text('收货地址')
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
    if (this.isLoading && this.addressList.length === 0) {
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#FF4D4F')
          .margin({ bottom: 12 })
        Text('加载中...')
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.addressList.length === 0) {
      Column() {
        Text('暂无收货地址')
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List({ space: 12 }) {
        ForEach(this.addressList, (address: Address) => {
          ListItem() {
            this.BuildAddressItem(address)
          }
        }, (address: Address) => address.addressId)
      }
      .width('100%')
      .layoutWeight(1)
      .padding(12)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  BuildAddressItem(address: Address) {
    Column() {
      Row() {
        Text(address.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Text(address.phone)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 12 })

        if (address.isDefault) {
          Text('默认')
            .fontSize(10)
            .fontColor('#FF4D4F')
            .backgroundColor('#FFF1F0')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
            .margin({ left: 8 })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 8 })

      Text(address.province + address.city + address.district + address.detail)
        .fontSize(14)
        .fontColor('#666666')
        .width('100%')
        .textAlign(TextAlign.Start)

      Divider()
        .color('#F0F0F0')
        .margin({ top: 12, bottom: 12 })

      Row() {
        Button() {
          Text('设为默认')
            .fontSize(13)
            .fontColor(address.isDefault ? '#999999' : '#666666')
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .enabled(!address.isDefault)
        .onClick(() => {
          this.setDefaultAddress(address);
        })

        Blank()

        Button() {
          Text('编辑')
            .fontSize(13)
            .fontColor('#666666')
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.editAddress(address);
        })

        Button() {
          Text('删除')
            .fontSize(13)
            .fontColor('#FF4D4F')
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.confirmDelete(address);
        })
      }
      .width('100%')
      .height(40)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder
  BuildAddButton() {
    Button('新增收货地址')
      .width('100%')
      .height(48)
      .borderRadius(24)
      .backgroundColor('#FF4D4F')
      .margin(16)
      .onClick(() => {
        this.addAddress();
      })
  }
}
