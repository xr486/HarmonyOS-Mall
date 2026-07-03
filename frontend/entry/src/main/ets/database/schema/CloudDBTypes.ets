/**
 * CloudDB 对象类型定义 — 仅端侧缓存
 *
 * 核心业务数据（用户、商品、订单、购物车、收货地址、支付流水）全部存 MySQL，
 * CloudDB 只作为移动端辅助存储：
 *   - 用户本地浏览记录（多设备同步，用于推荐算法）
 *   - 未提交的离线购物车（断网时暂存）
 *   - 设备偏好设置（主题、语言等，多设备同步）
 */

// ============================================================
// 端侧缓存表
// ============================================================

/** 浏览记录 — 用户浏览过的商品，用于推荐和"我的足迹" */
export class CloudDBBrowsingRecord {
  static className: string = 'browsing_record';
  recordId: string = '';
  userId: string = '';
  productId: string = '';
  productName: string = '';
  productImage: string = '';
  timestamp: number = Date.now();
}

/** 离线购物车 — 网络不可用时暂存的购物车项 */
export class CloudDBOfflineCartItem {
  static className: string = 'offline_cart_item';
  cartId: string = '';
  userId: string = '';
  productId: string = '';
  productName: string = '';
  productImage: string = '';
  price: number = 0;
  quantity: number = 1;
  specs: string = '';
  addedAt: number = Date.now();
}

/** 设备偏好设置 — 多设备同步的用户偏好 */
export class CloudDBDevicePreference {
  static className: string = 'device_preference';
  prefId: string = '';
  userId: string = '';
  prefKey: string = '';
  prefValue: string = '';
  updatedAt: number = Date.now();
}

// ============================================================
// 对象类型模式描述符
// ============================================================

interface CloudDBFieldInfo {
  fieldName: string;
  fieldType: string;
  belongPrimaryKey: boolean;
}

interface CloudDBObjectTypeDesc {
  objectTypeName: string;
  fields: CloudDBFieldInfo[];
}

export const CLOUD_DB_OBJECT_TYPES: CloudDBObjectTypeDesc[] = [
  {
    objectTypeName: 'browsing_record',
    fields: [
      { fieldName: 'recordId', fieldType: 'String', belongPrimaryKey: true },
      { fieldName: 'userId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'productId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'productName', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'productImage', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'timestamp', fieldType: 'Double', belongPrimaryKey: false }
    ]
  },
  {
    objectTypeName: 'offline_cart_item',
    fields: [
      { fieldName: 'cartId', fieldType: 'String', belongPrimaryKey: true },
      { fieldName: 'userId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'productId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'productName', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'productImage', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'price', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'quantity', fieldType: 'Integer', belongPrimaryKey: false },
      { fieldName: 'specs', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'addedAt', fieldType: 'Double', belongPrimaryKey: false }
    ]
  },
  {
    objectTypeName: 'device_preference',
    fields: [
      { fieldName: 'prefId', fieldType: 'String', belongPrimaryKey: true },
      { fieldName: 'userId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'prefKey', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'prefValue', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'updatedAt', fieldType: 'Double', belongPrimaryKey: false }
    ]
  }
];

// ============================================================
// 以下为旧版本业务表（已迁移至 MySQL，保留仅作参考）
// 如需清理 AGC CloudDB 侧旧表，请在 AppGallery Connect 控制台操作
// ============================================================
