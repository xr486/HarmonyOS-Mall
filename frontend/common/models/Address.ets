
/**
 * 收货地址数据模型
 */
export interface Address {
  /** 地址 ID */
  addressId: string;
  /** 用户 ID */
  userId: string;
  /** 收货人姓名 */
  name: string;
  /** 收货人电话 */
  phone: string;
  /** 省份 */
  province: string;
  /** 城市 */
  city: string;
  /** 区/县 */
  district: string;
  /** 详细地址 */
  detail: string;
  /** 是否默认地址 */
  isDefault: boolean;
  /** 创建时间戳 */
  createdAt: number;
  /** 更新时间戳 */
  updatedAt: number;
}
