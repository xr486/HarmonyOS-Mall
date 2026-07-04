import { AddressService } from '../services/user/AddressService';
import { Address } from '../common/models';
import { Logger } from '../common/utils/logger/Logger';
import { StorageUtil } from '../common/utils/storage/StorageUtil';
import { StorageKeys } from '../common/constants/StorageKeys';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

const TAG = 'AddressEdit';

class RegionItem {
  name: string = '';
  code: string = '';
  children: RegionItem[] = [];

  constructor(name: string, code: string, children?: RegionItem[]) {
    this.name = name;
    this.code = code;
    if (children) {
      this.children = children;
    }
  }
}

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

  private provinceData: RegionItem[] = [
    new RegionItem('北京市', '110000', [
      new RegionItem('东城区', '110101'), new RegionItem('西城区', '110102'),
      new RegionItem('朝阳区', '110105'), new RegionItem('海淀区', '110108'),
      new RegionItem('丰台区', '110106'), new RegionItem('石景山区', '110107')
    ]),
    new RegionItem('上海市', '310000', [
      new RegionItem('黄浦区', '310101'), new RegionItem('徐汇区', '310104'),
      new RegionItem('长宁区', '310105'), new RegionItem('静安区', '310106'),
      new RegionItem('浦东新区', '310115'), new RegionItem('虹口区', '310109')
    ]),
    new RegionItem('广东省', '440000', [
      new RegionItem('广州市', '440100', [
        new RegionItem('天河区', '440106'), new RegionItem('越秀区', '440104'),
        new RegionItem('海珠区', '440105'), new RegionItem('白云区', '440111'),
        new RegionItem('番禺区', '440113'), new RegionItem('黄埔区', '440112')
      ]),
      new RegionItem('深圳市', '440300', [
        new RegionItem('南山区', '440305'), new RegionItem('福田区', '440304'),
        new RegionItem('罗湖区', '440303'), new RegionItem('宝安区', '440306'),
        new RegionItem('龙岗区', '440307'), new RegionItem('龙华区', '440309')
      ]),
      new RegionItem('珠海市', '440400'), new RegionItem('东莞市', '441900')
    ]),
    new RegionItem('浙江省', '330000', [
      new RegionItem('杭州市', '330100', [
        new RegionItem('西湖区', '330106'), new RegionItem('上城区', '330102'),
        new RegionItem('拱墅区', '330105'), new RegionItem('滨江区', '330108'),
        new RegionItem('余杭区', '330110'), new RegionItem('萧山区', '330109')
      ]),
      new RegionItem('宁波市', '330200', [
        new RegionItem('海曙区', '330203'), new RegionItem('鄞州区', '330212'),
        new RegionItem('江北区', '330205'), new RegionItem('北仑区', '330206')
      ]),
      new RegionItem('温州市', '330300')
    ]),
    new RegionItem('江苏省', '320000', [
      new RegionItem('南京市', '320100', [
        new RegionItem('玄武区', '320102'), new RegionItem('鼓楼区', '320106'),
        new RegionItem('建邺区', '320105'), new RegionItem('江宁区', '320115')
      ]),
      new RegionItem('苏州市', '320500', [
        new RegionItem('姑苏区', '320508'), new RegionItem('虎丘区', '320505'),
        new RegionItem('吴中区', '320506'), new RegionItem('相城区', '320507')
      ]),
      new RegionItem('无锡市', '320200')
    ]),
    new RegionItem('四川省', '510000', [
      new RegionItem('成都市', '510100', [
        new RegionItem('武侯区', '510107'), new RegionItem('锦江区', '510104'),
        new RegionItem('青羊区', '510105'), new RegionItem('金牛区', '510106'),
        new RegionItem('成华区', '510108'), new RegionItem('高新区', '510190')
      ]),
      new RegionItem('绵阳市', '510700')
    ]),
    new RegionItem('湖北省', '420000', [
      new RegionItem('武汉市', '420100', [
        new RegionItem('武昌区', '420106'), new RegionItem('江岸区', '420102'),
        new RegionItem('洪山区', '420111'), new RegionItem('江汉区', '420103')
      ])
    ]),
    new RegionItem('福建省', '350000', [new RegionItem('福州市', '350100'), new RegionItem('厦门市', '350200')]),
    new RegionItem('山东省', '370000', [
      new RegionItem('济南市', '370100'), new RegionItem('青岛市', '370200')
    ]),
    new RegionItem('安徽省', '340000', [new RegionItem('合肥市', '340100')]),
    new RegionItem('湖南省', '430000', [new RegionItem('长沙市', '430100')]),
    new RegionItem('河北省', '130000', [new RegionItem('石家庄市', '130100')]),
    new RegionItem('河南省', '410000', [new RegionItem('郑州市', '410100')]),
    new RegionItem('辽宁省', '210000', [new RegionItem('沈阳市', '210100'), new RegionItem('大连市', '210200')]),
    new RegionItem('陕西省', '610000', [new RegionItem('西安市', '610100')]),
    new RegionItem('重庆市', '500000', [new RegionItem('渝中区', '500103'), new RegionItem('江北区', '500105')]),
    new RegionItem('天津市', '120000', [new RegionItem('和平区', '120101'), new RegionItem('南开区', '120104')])
  ];

  private provinces: string[] = [];
  private selectedProvinceIndex: number = 0;
  @State cities: string[] = ['请先选择省份'];
  private selectedCityIndex: number = 0;
  @State districts: string[] = ['请先选择城市'];
  private selectedDistrictIndex: number = 0;

  @State showRegionPicker: boolean = false;

  // Temp selection for picker
  @State tempProvinceIndex: number = 0;
  @State tempCityIndex: number = 0;
  @State tempDistrictIndex: number = 0;
  @State tempCities: string[] = [];
  @State tempDistricts: string[] = [];

  aboutToAppear(): void {
    this.initProvinceData();
    this.loadUserId();
    const params = router.getParams() as Record<string, string>;
    if (params && params['address']) {
      this.address = JSON.parse(params['address']) as Address;
      this.isEdit = true;
      this.initData();
    }
  }

  initProvinceData(): void {
    this.provinces = this.provinceData.map((p: RegionItem) => p.name);
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
      this.syncPickerPosition();
    }
  }

  syncPickerPosition(): void {
    const provIdx: number = this.provinceData.findIndex((p: RegionItem) => p.name === this.province);
    if (provIdx >= 0) {
      this.selectedProvinceIndex = provIdx;
      this.tempProvinceIndex = provIdx;
      this.cities = this.provinceData[provIdx].children.map((c: RegionItem) => c.name);
      const cityIdx: number = this.cities.findIndex((c: string) => c === this.city);
      if (cityIdx >= 0) {
        this.selectedCityIndex = cityIdx;
        this.tempCityIndex = cityIdx;
        const cityData: RegionItem = this.provinceData[provIdx].children[cityIdx];
        this.districts = cityData.children.map((d: RegionItem) => d.name);
        const distIdx: number = this.districts.findIndex((d: string) => d === this.district);
        if (distIdx >= 0) {
          this.selectedDistrictIndex = distIdx;
          this.tempDistrictIndex = distIdx;
        }
      }
    }
  }

  async loadUserId(): Promise<void> {
    const storage = StorageUtil.getInstance();
    const phone = await storage.getString(StorageKeys.USER_PHONE, '');
    this.userId = phone || 'unknown';
  }

  openRegionPicker(): void {
    this.tempProvinceIndex = this.selectedProvinceIndex;
    this.tempCityIndex = this.selectedCityIndex;
    this.tempDistrictIndex = this.selectedDistrictIndex;
    if (this.province) {
      const provIdx: number = this.provinceData.findIndex((p: RegionItem) => p.name === this.province);
      if (provIdx >= 0) {
        this.tempProvinceIndex = provIdx;
        this.tempCities = this.provinceData[provIdx].children.map((c: RegionItem) => c.name);
        if (this.city) {
          const cityIdx: number = this.tempCities.findIndex((c: string) => c === this.city);
          if (cityIdx >= 0) {
            this.tempCityIndex = cityIdx;
            this.tempDistricts = this.provinceData[provIdx].children[cityIdx].children
              .map((d: RegionItem) => d.name);
            if (this.district) {
              const distIdx: number = this.tempDistricts.findIndex((d: string) => d === this.district);
              if (distIdx >= 0) {
                this.tempDistrictIndex = distIdx;
              } else {
                this.tempDistrictIndex = 0;
              }
            }
          } else {
            this.tempCityIndex = 0;
            this.tempDistrictIndex = 0;
            const cityChildren: RegionItem[] = this.provinceData[provIdx].children[0].children;
            this.tempDistricts = cityChildren.map((d: RegionItem) => d.name);
          }
        }
      } else {
        this.tempProvinceIndex = 0;
        this.tempCities = this.provinceData[0].children.map((c: RegionItem) => c.name);
        this.tempCityIndex = 0;
        this.tempDistrictIndex = 0;
        const cityChildren: RegionItem[] = this.provinceData[0].children[0].children;
        this.tempDistricts = cityChildren.map((d: RegionItem) => d.name);
      }
    } else {
      this.tempProvinceIndex = 0;
      this.tempCities = this.provinceData[0].children.map((c: RegionItem) => c.name);
      this.tempCityIndex = 0;
      this.tempDistrictIndex = 0;
      const cityChildren: RegionItem[] = this.provinceData[0].children[0].children;
      this.tempDistricts = cityChildren.map((d: RegionItem) => d.name);
    }
    this.showRegionPicker = true;
  }

  onProvinceChange(index: number): void {
    if (index === this.tempProvinceIndex) {
      return;
    }
    this.tempProvinceIndex = index;
    const provinceItem: RegionItem = this.provinceData[index];
    this.tempCities = provinceItem.children.map((c: RegionItem) => c.name);
    this.tempCityIndex = 0;
    this.tempDistrictIndex = 0;
    const cityItem: RegionItem = provinceItem.children[0];
    this.tempDistricts = cityItem.children.map((d: RegionItem) => d.name);
  }

  onCityChange(index: number): void {
    if (index === this.tempCityIndex) {
      return;
    }
    this.tempCityIndex = index;
    const provinceItem: RegionItem = this.provinceData[this.tempProvinceIndex];
    const cityItem: RegionItem = provinceItem.children[index];
    this.tempDistrictIndex = 0;
    this.tempDistricts = cityItem.children.map((d: RegionItem) => d.name);
  }

  onDistrictChange(index: number): void {
    this.tempDistrictIndex = index;
  }

  confirmRegion(): void {
    const prov: RegionItem = this.provinceData[this.tempProvinceIndex];
    this.province = prov.name;
    this.selectedProvinceIndex = this.tempProvinceIndex;
    this.cities = this.tempCities;
    this.selectedCityIndex = this.tempCityIndex;

    const cityName: string = this.tempCities[this.tempCityIndex];
    this.city = cityName;

    const cityItem: RegionItem = prov.children[this.tempCityIndex];
    if (cityItem.children.length > 0) {
      this.district = this.tempDistricts[this.tempDistrictIndex];
      this.selectedDistrictIndex = this.tempDistrictIndex;
      this.districts = this.tempDistricts;
    } else {
      this.district = cityName;
      this.selectedDistrictIndex = 0;
    }

    this.regionText = this.province + this.city + this.district;
    this.showRegionPicker = false;
  }

  cancelRegion(): void {
    this.showRegionPicker = false;
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
    Stack() {
      Column() {
        this.BuildHeader()
        this.BuildContent()
        this.BuildSaveButton()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      if (this.showRegionPicker) {
        Column() {
          Column() {
            Row() {
              Text('取消')
                .fontSize(16)
                .fontColor('#666')
                .onClick(() => { this.cancelRegion(); })
              Text('请选择所在地区')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
              Text('确定')
                .fontSize(16)
                .fontColor('#FF4D4F')
                .onClick(() => { this.confirmRegion(); })
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 16 })

            Divider().height(1).backgroundColor('#F0F0F0')

            Row() {
              TextPicker({ range: this.provinces, selected: this.tempProvinceIndex })
                .layoutWeight(1)
                .height(200)
                .onChange((value: string | string[], index: number | number[]) => {
                  this.onProvinceChange(index as number);
                })

              TextPicker({ range: this.tempCities, selected: this.tempCityIndex })
                .layoutWeight(1)
                .height(200)
                .onChange((value: string | string[], index: number | number[]) => {
                  this.onCityChange(index as number);
                })

              TextPicker({ range: this.tempDistricts, selected: this.tempDistrictIndex })
                .layoutWeight(1)
                .height(200)
                .onChange((value: string | string[], index: number | number[]) => {
                  this.onDistrictChange(index as number);
                })
            }
            .width('100%')
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius({ topLeft: 12, topRight: 12 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .justifyContent(FlexAlign.End)
      }
    }
    .width('100%')
    .height('100%')
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
      this.openRegionPicker();
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
