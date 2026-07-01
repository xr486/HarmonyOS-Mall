import { DatabaseHelper } from '../../database/helper';
import { CloudDBAddress } from '../../database/schema/CloudDBTypes';
import { Address } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'AddressService';

export class AddressService {
  private static instance: AddressService | null = null;
  private dbHelper: DatabaseHelper;

  private constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  static getInstance(): AddressService {
    if (!AddressService.instance) {
      AddressService.instance = new AddressService();
    }
    return AddressService.instance;
  }

  private convertToAddress(cloudAddress: CloudDBAddress): Address {
    return {
      addressId: cloudAddress.addressId || '',
      userId: cloudAddress.userId || '',
      name: cloudAddress.name || '',
      phone: cloudAddress.phone || '',
      province: cloudAddress.province || '',
      city: cloudAddress.city || '',
      district: cloudAddress.district || '',
      detail: cloudAddress.detail || '',
      isDefault: cloudAddress.isDefault || false,
      createdAt: cloudAddress.createdAt || Date.now(),
      updatedAt: cloudAddress.updatedAt || Date.now()
    };
  }

  private convertToCloudAddress(address: Address): CloudDBAddress {
    const cloudAddress = new CloudDBAddress();
    cloudAddress.addressId = address.addressId;
    cloudAddress.userId = address.userId;
    cloudAddress.name = address.name;
    cloudAddress.phone = address.phone;
    cloudAddress.province = address.province;
    cloudAddress.city = address.city;
    cloudAddress.district = address.district;
    cloudAddress.detail = address.detail;
    cloudAddress.isDefault = address.isDefault;
    cloudAddress.createdAt = address.createdAt;
    cloudAddress.updatedAt = address.updatedAt;
    return cloudAddress;
  }

  async getAddressesByUserId(userId: string): Promise<Address[]> {
    try {
      const allAddresses = await this.dbHelper.queryAll(CloudDBAddress);
      return allAddresses.filter(a => a.userId === userId).map(this.convertToAddress);
    } catch (error) {
      Logger.error(TAG, 'Failed to get addresses: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  async getDefaultAddress(userId: string): Promise<Address | null> {
    try {
      const addresses = await this.getAddressesByUserId(userId);
      return addresses.find(a => a.isDefault) || null;
    } catch (error) {
      Logger.error(TAG, 'Failed to get default address: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  async addAddress(address: Address): Promise<void> {
    try {
      if (address.isDefault) {
        const existingAddresses = await this.getAddressesByUserId(address.userId);
        for (const addr of existingAddresses) {
          if (addr.isDefault) {
            addr.isDefault = false;
            addr.updatedAt = Date.now();
            const cloudAddr = this.convertToCloudAddress(addr);
            await this.dbHelper.update(cloudAddr);
          }
        }
      }

      const cloudAddress = this.convertToCloudAddress(address);
      await this.dbHelper.insert(cloudAddress);
      Logger.info(TAG, 'Address added successfully: %{public}s', address.addressId);
    } catch (error) {
      Logger.error(TAG, 'Failed to add address: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  async updateAddress(address: Address): Promise<void> {
    try {
      if (address.isDefault) {
        const existingAddresses = await this.getAddressesByUserId(address.userId);
        for (const addr of existingAddresses) {
          if (addr.addressId !== address.addressId && addr.isDefault) {
            addr.isDefault = false;
            addr.updatedAt = Date.now();
            const cloudAddr = this.convertToCloudAddress(addr);
            await this.dbHelper.update(cloudAddr);
          }
        }
      }

      const cloudAddress = this.convertToCloudAddress(address);
      await this.dbHelper.update(cloudAddress);
      Logger.info(TAG, 'Address updated successfully: %{public}s', address.addressId);
    } catch (error) {
      Logger.error(TAG, 'Failed to update address: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  async deleteAddress(addressId: string): Promise<void> {
    try {
      const cloudAddress = await this.dbHelper.queryById(CloudDBAddress, 'addressId', addressId);
      if (cloudAddress) {
        await this.dbHelper.delete(cloudAddress);
        Logger.info(TAG, 'Address deleted successfully: %{public}s', addressId);
      }
    } catch (error) {
      Logger.error(TAG, 'Failed to delete address: %{public}s', JSON.stringify(error));
      throw error;
    }
  }
}
