import { HttpUtil, ApiResponse, AddressBody } from '../../common/utils/http/HttpUtil';
import { Address } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'AddressService';

export class AddressService {
  private static instance: AddressService | null = null;

  private constructor() {
  }

  static getInstance(): AddressService {
    if (!AddressService.instance) {
      AddressService.instance = new AddressService();
    }
    return AddressService.instance;
  }

  async getAddressesByUser(userId: string): Promise<Address[]> {
    try {
      const res: ApiResponse<Address[]> = await HttpUtil.get('/addresses');
      if (res.code === 200 && res.data) {
        return res.data;
      }
      return [];
    } catch (e) {
      Logger.error(TAG, 'getAddressesByUser error: %{public}s', JSON.stringify(e));
      return [];
    }
  }

  async addAddress(address: Address): Promise<Address | null> {
    try {
      const body: AddressBody = new AddressBody();
      body.name = address.name;
      body.phone = address.phone;
      body.province = address.province;
      body.city = address.city;
      body.district = address.district;
      body.detail = address.detail;
      body.isDefault = address.isDefault || false;
      const res: ApiResponse<Address> = await HttpUtil.post('/addresses', body);
      if (res.code === 200) {
        return res.data;
      }
      Logger.error(TAG, 'addAddress failed: %{public}s', res.message);
      return null;
    } catch (e) {
      Logger.error(TAG, 'addAddress error: %{public}s', JSON.stringify(e));
      return null;
    }
  }

  async updateAddress(address: Address): Promise<Address | null> {
    try {
      const body: AddressBody = new AddressBody();
      body.name = address.name;
      body.phone = address.phone;
      body.province = address.province;
      body.city = address.city;
      body.district = address.district;
      body.detail = address.detail;
      body.isDefault = address.isDefault || false;
      const res: ApiResponse<Address> = await HttpUtil.put('/addresses/' + address.addressId, body);
      if (res.code === 200) {
        return res.data;
      }
      Logger.error(TAG, 'updateAddress failed: %{public}s', res.message);
      return null;
    } catch (e) {
      Logger.error(TAG, 'updateAddress error: %{public}s', JSON.stringify(e));
      return null;
    }
  }

  async deleteAddress(addressId: string): Promise<boolean> {
    try {
      const res: ApiResponse<string> = await HttpUtil.delete('/addresses/' + addressId);
      return res.code === 200;
    } catch (e) {
      Logger.error(TAG, 'deleteAddress error: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  async setDefaultAddress(addressId: string): Promise<boolean> {
    try {
      const res: ApiResponse<Address> = await HttpUtil.put('/addresses/' + addressId + '/default');
      return res.code === 200;
    } catch (e) {
      Logger.error(TAG, 'setDefaultAddress error: %{public}s', JSON.stringify(e));
      return false;
    }
  }
}
