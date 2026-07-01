import { DatabaseHelper } from '../../database/helper/DatabaseHelper';
import { CloudDBCartItem } from '../../database/schema/CloudDBTypes';
import { CartItem } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'CartService';

export class CartService {
  private static instance: CartService | null = null;
  private dbHelper: DatabaseHelper;

  private constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  static getInstance(): CartService {
    if (!CartService.instance) {
      CartService.instance = new CartService();
    }
    return CartService.instance;
  }

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

  private convertToCloudCartItem(cartItem: CartItem): CloudDBCartItem {
    const cloudCartItem: CloudDBCartItem = new CloudDBCartItem();
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

  async getCartItems(userId: string): Promise<CartItem[]> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        const empty: CartItem[] = [];
        return empty;
      }
      const collection = db.collection(CloudDBCartItem);
      const cloudCartItems: CloudDBCartItem[] = await collection.query().get();
      return cloudCartItems
        .filter((item: CloudDBCartItem) => item.userId === userId)
        .map((item: CloudDBCartItem) => this.convertToCartItem(item));
    } catch (error) {
      Logger.error(TAG, 'Failed to get cart items: %{public}s', JSON.stringify(error));
      throw new Error('Failed to get cart items: ' + JSON.stringify(error));
    }
  }

  async addToCart(cartItem: CartItem): Promise<void> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return;
      }
      const cloudCartItem: CloudDBCartItem = this.convertToCloudCartItem(cartItem);
      const collection = db.collection(CloudDBCartItem);
      await collection.upsert(cloudCartItem);
      Logger.info(TAG, 'Item added to cart: %{public}s', cartItem.cartId);
    } catch (error) {
      Logger.error(TAG, 'Failed to add item to cart: %{public}s', JSON.stringify(error));
      throw new Error('Failed to add item to cart: ' + JSON.stringify(error));
    }
  }

  async updateCartItemQuantity(cartId: string, quantity: number): Promise<void> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return;
      }
      const collection = db.collection(CloudDBCartItem);
      const cartItems: CloudDBCartItem[] = await collection.query().equalTo('cartId', cartId).get();
      if (cartItems.length > 0) {
        cartItems[0].quantity = quantity;
        await collection.upsert(cartItems[0]);
        Logger.info(TAG, 'Cart item quantity updated: %{public}s', cartId);
      }
    } catch (error) {
      Logger.error(TAG, 'Failed to update cart item quantity: %{public}s', JSON.stringify(error));
      throw new Error('Failed to update cart item quantity: ' + JSON.stringify(error));
    }
  }

  async updateCartItemSelected(cartId: string, selected: boolean): Promise<void> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return;
      }
      const collection = db.collection(CloudDBCartItem);
      const cartItems: CloudDBCartItem[] = await collection.query().equalTo('cartId', cartId).get();
      if (cartItems.length > 0) {
        cartItems[0].selected = selected;
        await collection.upsert(cartItems[0]);
        Logger.info(TAG, 'Cart item selected updated: %{public}s', cartId);
      }
    } catch (error) {
      Logger.error(TAG, 'Failed to update cart item selected: %{public}s', JSON.stringify(error));
      throw new Error('Failed to update cart item selected: ' + JSON.stringify(error));
    }
  }

  async removeFromCart(cartId: string): Promise<void> {
    try {
      const db = this.dbHelper.getDatabase();
      if (!db) {
        return;
      }
      const collection = db.collection(CloudDBCartItem);
      const cartItems: CloudDBCartItem[] = await collection.query().equalTo('cartId', cartId).get();
      if (cartItems.length > 0) {
        await collection.delete(cartItems[0]);
        Logger.info(TAG, 'Item removed from cart: %{public}s', cartId);
      }
    } catch (error) {
      Logger.error(TAG, 'Failed to remove item from cart: %{public}s', JSON.stringify(error));
      throw new Error('Failed to remove item from cart: ' + JSON.stringify(error));
    }
  }

  async calculateTotal(userId: string): Promise<number> {
    try {
      const cartItems: CartItem[] = await this.getCartItems(userId);
      const selectedItems: CartItem[] = cartItems.filter((item: CartItem) => item.selected);
      let total: number = 0;
      for (const item of selectedItems) {
        total = total + (item.price * item.quantity);
      }
      return total;
    } catch (error) {
      Logger.error(TAG, 'Failed to calculate total: %{public}s', JSON.stringify(error));
      throw new Error('Failed to calculate total: ' + JSON.stringify(error));
    }
  }
}
