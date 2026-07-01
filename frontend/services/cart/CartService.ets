
import { DatabaseHelper } from '../../database/helper';
import { CloudDBCartItem } from '../../database/schema/CloudDBTypes';
import { CartItem } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'CartService';

/**
 * 购物车服务类
 */
export class CartService {
  private static instance: CartService | null = null;
  private dbHelper: DatabaseHelper;

  private constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  /**
   * 获取单例实例
   */
  static getInstance(): CartService {
    if (!CartService.instance) {
      CartService.instance = new CartService();
    }
    return CartService.instance;
  }

  /**
   * 将 CloudDBCartItem 转换为 CartItem
   */
  private convertToCartItem(cloudCartItem: CloudDBCartItem): CartItem {
    return {
      cartId: cloudCartItem.cartId || '',
      userId: cloudCartItem.userId || '',
      productId: cloudCartItem.productId || '',
      productName: cloudCartItem.productName || '',
      productImage: cloudCartItem.productImage || '',
      price: cloudCartItem.price || 0,
      quantity: cloudCartItem.quantity || 1,
      selected: cloudCartItem.selected || false,
      stock: cloudCartItem.stock || 0,
      addedAt: cloudCartItem.addedAt || Date.now()
    };
  }

  /**
   * 将 CartItem 转换为 CloudDBCartItem
   */
  private convertToCloudCartItem(cartItem: CartItem): CloudDBCartItem {
    const cloudCartItem = new CloudDBCartItem();
    cloudCartItem.cartId = cartItem.cartId;
    cloudCartItem.userId = cartItem.userId;
    cloudCartItem.productId = cartItem.productId;
    cloudCartItem.productName = cartItem.productName;
    cloudCartItem.productImage = cartItem.productImage;
    cloudCartItem.price = cartItem.price;
    cloudCartItem.quantity = cartItem.quantity;
    cloudCartItem.selected = cartItem.selected;
    cloudCartItem.stock = cartItem.stock;
    cloudCartItem.addedAt = cartItem.addedAt;
    return cloudCartItem;
  }

  /**
   * 获取用户购物车列表
   */
  async getCartItems(userId: string): Promise<CartItem[]> {
    try {
      const allCartItems = await this.dbHelper.queryAll(CloudDBCartItem);
      return allCartItems.filter(item => item.userId === userId).map(this.convertToCartItem);
    } catch (error) {
      Logger.error(TAG, 'Failed to get cart items: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 添加商品到购物车
   */
  async addToCart(cartItem: CartItem): Promise<void> {
    try {
      const cloudCartItem = this.convertToCloudCartItem(cartItem);
      await this.dbHelper.insert(cloudCartItem);
      Logger.info(TAG, 'Item added to cart: %{public}s', cartItem.cartId);
    } catch (error) {
      Logger.error(TAG, 'Failed to add item to cart: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 更新购物车商品数量
   */
  async updateCartItemQuantity(cartId: string, quantity: number): Promise<void> {
    try {
      const cartItem = await this.dbHelper.queryById(CloudDBCartItem, 'cartId', cartId);
      if (cartItem) {
        cartItem.quantity = quantity;
        await this.dbHelper.update(cartItem);
        Logger.info(TAG, 'Cart item quantity updated: %{public}s', cartId);
      }
    } catch (error) {
      Logger.error(TAG, 'Failed to update cart item quantity: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 更新选中状态
   */
  async updateCartItemSelected(cartId: string, selected: boolean): Promise<void> {
    try {
      const cartItem = await this.dbHelper.queryById(CloudDBCartItem, 'cartId', cartId);
      if (cartItem) {
        cartItem.selected = selected;
        await this.dbHelper.update(cartItem);
        Logger.info(TAG, 'Cart item selected updated: %{public}s', cartId);
      }
    } catch (error) {
      Logger.error(TAG, 'Failed to update cart item selected: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 删除购物车商品
   */
  async removeFromCart(cartId: string): Promise<void> {
    try {
      const cartItem = await this.dbHelper.queryById(CloudDBCartItem, 'cartId', cartId);
      if (cartItem) {
        await this.dbHelper.delete(cartItem);
        Logger.info(TAG, 'Item removed from cart: %{public}s', cartId);
      }
    } catch (error) {
      Logger.error(TAG, 'Failed to remove item from cart: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 计算购物车选中商品总金额
   */
  async calculateTotal(userId: string): Promise<number> {
    try {
      const cartItems = await this.getCartItems(userId);
      const selectedItems = cartItems.filter(item => item.selected);
      return selectedItems.reduce((total, item) => total + (item.price * item.quantity), 0);
    } catch (error) {
      Logger.error(TAG, 'Failed to calculate total: %{public}s', JSON.stringify(error));
      throw error;
    }
  }
}
