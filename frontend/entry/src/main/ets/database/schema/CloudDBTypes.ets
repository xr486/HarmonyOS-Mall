/**
 * CloudDB 对象类型定义
 */

export class CloudDBUser {
  static className: string = 'user_table';
  userId: string = '';
  phone: string = '';
  nickname: string = '';
  avatar: string = '';
  huaweiAccount: string = '';
  createdAt: number = Date.now();
  updatedAt: number = Date.now();
}

export class CloudDBAddress {
  static className: string = 'address_table';
  addressId: string = '';
  userId: string = '';
  name: string = '';
  phone: string = '';
  province: string = '';
  city: string = '';
  district: string = '';
  detail: string = '';
  isDefault: boolean = false;
  createdAt: number = Date.now();
  updatedAt: number = Date.now();
}

export class CloudDBCategory {
  static className: string = 'category_table';
  categoryId: string = '';
  name: string = '';
  icon: string = '';
  parentId: string = '';
  sortOrder: number = 0;
  createdAt: number = Date.now();
  updatedAt: number = Date.now();
}

export class CloudDBProduct {
  static className: string = 'product_table';
  productId: string = '';
  name: string = '';
  description: string = '';
  price: number = 0;
  originalPrice: number = 0;
  stock: number = 0;
  images: string = '';
  brand: string = '';
  categoryId: string = '';
  rating: number = 0;
  salesCount: number = 0;
  specs: string = '';
  latitude: number = 0;
  longitude: number = 0;
  createdAt: number = Date.now();
}

export class CloudDBCartItem {
  static className: string = 'cart_item_table';
  cartId: string = '';
  userId: string = '';
  productId: string = '';
  productName: string = '';
  productImage: string = '';
  price: number = 0;
  quantity: number = 0;
  selected: boolean = false;
  stock: number = 0;
  addedAt: number = Date.now();
}

export class CloudDBOrderItem {
  static className: string = 'order_item_table';
  orderItemId: string = '';
  orderId: string = '';
  productId: string = '';
  productName: string = '';
  productImage: string = '';
  price: number = 0;
  quantity: number = 0;
}

export class CloudDBOrder {
  static className: string = 'order_table';
  orderId: string = '';
  orderNo: string = '';
  userId: string = '';
  totalAmount: number = 0;
  status: string = '';
  items: string = '';
  address: string = '';
  paymentMethod: string = '';
  paymentStatus: string = '';
  remark: string = '';
  createdAt: number = Date.now();
  paidAt: number = 0;
  completedAt: number = 0;
  expireTime: number = 0;
}

export class CloudDBPayment {
  static className: string = 'payment_table';
  paymentId: string = '';
  orderId: string = '';
  userId: string = '';
  amount: number = 0;
  method: string = '';
  status: string = '';
  transactionId: string = '';
  createdAt: number = Date.now();
  paidAt: number = 0;
}

/** 对象类型模式描述符 */

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
    objectTypeName: 'user_table',
    fields: [
      { fieldName: 'userId', fieldType: 'String', belongPrimaryKey: true },
      { fieldName: 'phone', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'nickname', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'avatar', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'huaweiAccount', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'createdAt', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'updatedAt', fieldType: 'Double', belongPrimaryKey: false }
    ]
  },
  {
    objectTypeName: 'address_table',
    fields: [
      { fieldName: 'addressId', fieldType: 'String', belongPrimaryKey: true },
      { fieldName: 'userId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'name', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'phone', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'province', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'city', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'district', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'detail', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'isDefault', fieldType: 'Boolean', belongPrimaryKey: false },
      { fieldName: 'createdAt', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'updatedAt', fieldType: 'Double', belongPrimaryKey: false }
    ]
  },
  {
    objectTypeName: 'category_table',
    fields: [
      { fieldName: 'categoryId', fieldType: 'String', belongPrimaryKey: true },
      { fieldName: 'name', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'icon', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'parentId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'sortOrder', fieldType: 'Integer', belongPrimaryKey: false },
      { fieldName: 'createdAt', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'updatedAt', fieldType: 'Double', belongPrimaryKey: false }
    ]
  },
  {
    objectTypeName: 'product_table',
    fields: [
      { fieldName: 'productId', fieldType: 'String', belongPrimaryKey: true },
      { fieldName: 'name', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'description', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'price', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'originalPrice', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'stock', fieldType: 'Integer', belongPrimaryKey: false },
      { fieldName: 'images', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'brand', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'categoryId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'rating', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'salesCount', fieldType: 'Integer', belongPrimaryKey: false },
      { fieldName: 'specs', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'latitude', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'longitude', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'createdAt', fieldType: 'Double', belongPrimaryKey: false }
    ]
  },
  {
    objectTypeName: 'cart_item_table',
    fields: [
      { fieldName: 'cartId', fieldType: 'String', belongPrimaryKey: true },
      { fieldName: 'userId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'productId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'productName', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'productImage', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'price', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'quantity', fieldType: 'Integer', belongPrimaryKey: false },
      { fieldName: 'selected', fieldType: 'Boolean', belongPrimaryKey: false },
      { fieldName: 'stock', fieldType: 'Integer', belongPrimaryKey: false },
      { fieldName: 'addedAt', fieldType: 'Double', belongPrimaryKey: false }
    ]
  },
  {
    objectTypeName: 'order_item_table',
    fields: [
      { fieldName: 'orderItemId', fieldType: 'String', belongPrimaryKey: true },
      { fieldName: 'orderId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'productId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'productName', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'productImage', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'price', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'quantity', fieldType: 'Integer', belongPrimaryKey: false }
    ]
  },
  {
    objectTypeName: 'order_table',
    fields: [
      { fieldName: 'orderId', fieldType: 'String', belongPrimaryKey: true },
      { fieldName: 'orderNo', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'userId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'totalAmount', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'status', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'items', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'address', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'paymentMethod', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'paymentStatus', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'remark', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'createdAt', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'paidAt', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'completedAt', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'expireTime', fieldType: 'Double', belongPrimaryKey: false }
    ]
  },
  {
    objectTypeName: 'payment_table',
    fields: [
      { fieldName: 'paymentId', fieldType: 'String', belongPrimaryKey: true },
      { fieldName: 'orderId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'userId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'amount', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'method', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'status', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'transactionId', fieldType: 'String', belongPrimaryKey: false },
      { fieldName: 'createdAt', fieldType: 'Double', belongPrimaryKey: false },
      { fieldName: 'paidAt', fieldType: 'Double', belongPrimaryKey: false }
    ]
  }
];
