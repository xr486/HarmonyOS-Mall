
/**
 * CloudDB 对象类型基类
 */
export abstract class CloudDBObject {
  abstract getClassName(): string;
}

/**
 * 用户 - CloudDB 对象类型
 */
export class CloudDBUser extends CloudDBObject {
  userId?: string;
  phone?: string;
  nickname?: string;
  avatar?: string;
  huaweiAccount?: string;
  createdAt?: number;
  updatedAt?: number;

  getClassName(): string {
    return 'User';
  }
}

/**
 * 收货地址 - CloudDB 对象类型
 */
export class CloudDBAddress extends CloudDBObject {
  addressId?: string;
  userId?: string;
  name?: string;
  phone?: string;
  province?: string;
  city?: string;
  district?: string;
  detail?: string;
  isDefault?: boolean;
  createdAt?: number;
  updatedAt?: number;

  getClassName(): string {
    return 'Address';
  }
}

/**
 * 商品分类 - CloudDB 对象类型
 */
export class CloudDBCategory extends CloudDBObject {
  categoryId?: string;
  name?: string;
  icon?: string;
  parentId?: string;
  sortOrder?: number;
  createdAt?: number;
  updatedAt?: number;

  getClassName(): string {
    return 'Category';
  }
}

/**
 * 商品 - CloudDB 对象类型
 */
export class CloudDBProduct extends CloudDBObject {
  productId?: string;
  name?: string;
  description?: string;
  price?: number;
  originalPrice?: number;
  stock?: number;
  images?: string; // JSON 字符串存储
  brand?: string;
  categoryId?: string;
  rating?: number;
  salesCount?: number;
  specs?: string; // JSON 字符串存储
  latitude?: number;
  longitude?: number;
  createdAt?: number;

  getClassName(): string {
    return 'Product';
  }
}

/**
 * 购物车项 - CloudDB 对象类型
 */
export class CloudDBCartItem extends CloudDBObject {
  cartId?: string;
  userId?: string;
  productId?: string;
  productName?: string;
  productImage?: string;
  price?: number;
  quantity?: number;
  selected?: boolean;
  stock?: number;
  addedAt?: number;

  getClassName(): string {
    return 'CartItem';
  }
}

/**
 * 订单项 - CloudDB 对象类型
 */
export class CloudDBOrderItem extends CloudDBObject {
  itemId?: string;
  orderId?: string;
  productId?: string;
  productName?: string;
  productImage?: string;
  price?: number;
  quantity?: number;
  spec?: string;

  getClassName(): string {
    return 'OrderItem';
  }
}

/**
 * 订单 - CloudDB 对象类型
 */
export class CloudDBOrder extends CloudDBObject {
  orderId?: string;
  orderNo?: string;
  userId?: string;
  totalAmount?: number;
  status?: number;
  address?: string; // JSON 字符串存储
  payment?: string; // JSON 字符串存储
  remark?: string;
  createdAt?: number;
  paidAt?: number;
  completedAt?: number;
  expireTime?: number;

  getClassName(): string {
    return 'Order';
  }
}

/**
 * 支付信息 - CloudDB 对象类型
 */
export class CloudDBPayment extends CloudDBObject {
  paymentId?: string;
  orderId?: string;
  amount?: number;
  method?: number;
  status?: number;
  transactionId?: string;
  paidAt?: number;

  getClassName(): string {
    return 'Payment';
  }
}
