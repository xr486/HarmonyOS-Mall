import { DatabaseHelper } from '../../database/helper/DatabaseHelper';
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
    const cloudAddress: CloudDBAddress = new CloudDBAddress();
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
      const db = this.dbHelper.getDatabase();
      if (!db) {
        const empty: Address[] = [];
        return empty;
      }
      const collection = db.collection(CloudDBAddress);
      const cloudAddresses: CloudDBAddress[] = await collection.query().get();
      return cloudAddresses
        .filter((a: CloudDBAddress) => a.userId === userId)
        .map((item: CloudDBAddress) => this.convertToAddress(item));
    } catch (error) {
      Logger.error(TAG, 'Failed to get addresses: %{public}s', JSON.stringify(error));
      throw new Error('Failed to get addresses: ' + JSON.stringify(error));
    }
  }

  async getDefaultAddress(userId: string): Promise<Address | null> {
    try {
      const addresses: Address[] = await this.getAddressesByUserId(userId);
      const found: Address | undefined = addresses.find((a: Address) => a.isDefault);
      return found || null;
    } catch (error) {
      Logger.error(TAG, 'Failed to get default address: %{public}s', JSON.stringify(error));
      throw new Error('Failed to get default address: ' + JSON.stringify(error));
    }
  }

  async addAddress(address: Address): Promise<void> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return;
      }
      if (address.isDefault) {
        const existingAddresses: Address[] = await this.getAddressesByUserId(address.userId);
        const collection = db.collection(CloudDBAddress);
        for (const addr of existingAddresses) {
          if (addr.isDefault) {
            addr.isDefault = false;
            addr.updatedAt = Date.now();
            const cloudAddr: CloudDBAddress = this.convertToCloudAddress(addr);
            await collection.upsert(cloudAddr);
          }
        }
      }

      const cloudAddress: CloudDBAddress = this.convertToCloudAddress(address);
      const collection = db.collection(CloudDBAddress);
      await collection.upsert(cloudAddress);
      Logger.info(TAG, 'Address added successfully: %{public}s', address.addressId);
    } catch (error) {
      Logger.error(TAG, 'Failed to add address: %{public}s', JSON.stringify(error));
      throw new Error('Failed to add address: ' + JSON.stringify(error));
    }
  }

  async updateAddress(address: Address): Promise<void> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return;
      }
      if (address.isDefault) {
        const existingAddresses: Address[] = await this.getAddressesByUserId(address.userId);
        const collection = db.collection(CloudDBAddress);
        for (const addr of existingAddresses) {
          if (addr.addressId !== address.addressId && addr.isDefault) {
            addr.isDefault = false;
            addr.updatedAt = Date.now();
            const cloudAddr: CloudDBAddress = this.convertToCloudAddress(addr);
            await collection.upsert(cloudAddr);
          }
        }
      }

      const cloudAddress: CloudDBAddress = this.convertToCloudAddress(address);
      const collection = db.collection(CloudDBAddress);
      await collection.upsert(cloudAddress);
      Logger.info(TAG, 'Address updated successfully: %{public}s', address.addressId);
    } catch (error) {
      Logger.error(TAG, 'Failed to update address: %{public}s', JSON.stringify(error));
      throw new Error('Failed to update address: ' + JSON.stringify(error));
    }
  }

  async deleteAddress(addressId: string): Promise<void> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return;
      }
      const collection = db.collection(CloudDBAddress);
      const cloudAddresses: CloudDBAddress[] = await collection.query().equalTo('addressId', addressId).get();
      if (cloudAddresses.length > 0) {
        await collection.delete(cloudAddresses[0]);
        Logger.info(TAG, 'Address deleted successfully: %{public}s', addressId);
      }
    } catch (error) {
      Logger.error(TAG, 'Failed to delete address: %{public}s', JSON.stringify(error));
      throw new Error('Failed to delete address: ' + JSON.stringify(error));
    }
  }
}
