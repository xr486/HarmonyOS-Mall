import { HttpUtil, ApiResponse, AddCartBody, UpdateCartBody, UpdateCartCheckedBody, UpdateCartQuantityBody } from '../../common/utils/http/HttpUtil';
import { CartItem } from '../../common/models';
import { Logger } from '../../common/utils/logger/Logger';

const TAG = 'CartService';

export class CartService {
  private static instance: CartService | null = null;

  private constructor() {
  }

  static getInstance(): CartService {
    if (!CartService.instance) {
      CartService.instance = new CartService();
    }
    return CartService.instance;
  }

  async getCartItems(userId: string): Promise<CartItem[]> {
    try {
      const res: ApiResponse<CartItem[]> = await HttpUtil.get('/cart');
      if (res.code === 200 && res.data) {
        Logger.info(TAG, 'getCartItems raw: %{public}s', JSON.stringify(res.data));
        const items: CartItem[] = [];
        for (let i: number = 0; i < res.data.length; i++) {
          const raw: CartItem = res.data[i];
          // 优先用后端 checked，其次用 selected，默认 true
          let selected: boolean = true;
          if (raw.checked !== undefined && raw.checked !== null) {
            selected = raw.checked;
          } else if (raw.selected !== undefined && raw.selected !== null) {
            selected = raw.selected;
          }
          items.push({
            cartId: raw.cartId,
            userId: raw.userId,
            productId: raw.productId,
            productName: raw.productName,
            productImage: raw.productImage,
            price: raw.price,
            quantity: raw.quantity,
            selected: selected,
            stock: raw.stock ?? 99,
            specs: raw.specs ?? '',
            createdAt: raw.createdAt ?? 0,
            updatedAt: raw.updatedAt ?? 0,
            addedAt: raw.addedAt ?? raw.createdAt ?? Date.now()
          });
        }
        Logger.info(TAG, 'getCartItems parsed %{public}d items', items.length);
        return items;
      }
      Logger.warn(TAG, 'getCartItems: code=%{public}d, data=%{public}s', res.code, JSON.stringify(res.data));
      return [];
    } catch (e) {
      Logger.error(TAG, 'getCartItems error: %{public}s', JSON.stringify(e));
      return [];
    }
  }

  async addToCart(cartItem: CartItem): Promise<boolean> {
    try {
      const body: AddCartBody = new AddCartBody();
      body.productId = cartItem.productId;
      body.productName = cartItem.productName;
      body.productImage = cartItem.productImage;
      body.price = cartItem.price;
      body.quantity = cartItem.quantity;
      body.specs = '';
      const res: ApiResponse<Object> = await HttpUtil.post('/cart', body);
      if (res.code === 200) {
        Logger.info(TAG, 'Item added to cart');
        return true;
      }
      return false;
    } catch (e) {
      Logger.error(TAG, 'addToCart error: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  async updateCartItemQuantity(cartId: string, quantity: number): Promise<boolean> {
    try {
      const body: UpdateCartQuantityBody = new UpdateCartQuantityBody();
      body.quantity = quantity;
      const res: ApiResponse<Object> = await HttpUtil.put('/cart/' + cartId, body);
      if (res.code === 200) {
        Logger.info(TAG, 'Cart item quantity updated: %{public}s', cartId);
        return true;
      }
      return false;
    } catch (e) {
      Logger.error(TAG, 'updateCartItemQuantity error: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  async removeFromCart(cartId: string): Promise<boolean> {
    try {
      const res: ApiResponse<Object> = await HttpUtil.delete('/cart/' + cartId);
      if (res.code === 200) {
        Logger.info(TAG, 'Item removed from cart: %{public}s', cartId);
        return true;
      }
      return false;
    } catch (e) {
      Logger.error(TAG, 'removeFromCart error: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  async clearCart(): Promise<boolean> {
    try {
      const res: ApiResponse<Object> = await HttpUtil.delete('/cart/clear');
      if (res.code === 200) {
        return true;
      }
      return false;
    } catch (e) {
      Logger.error(TAG, 'clearCart error: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  async updateCartItemChecked(cartId: string, checked: boolean): Promise<boolean> {
    try {
      const body: UpdateCartCheckedBody = new UpdateCartCheckedBody();
      body.checked = checked;
      const res: ApiResponse<Object> = await HttpUtil.put('/cart/' + cartId, body);
      if (res.code === 200) {
        Logger.info(TAG, 'Cart item checked state updated: %{public}s', cartId);
        return true;
      }
      return false;
    } catch (e) {
      Logger.error(TAG, 'updateCartItemChecked error: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  async selectAll(cartIds: string[], checked: boolean): Promise<boolean> {
    try {
      let successCount: number = 0;
      for (let i: number = 0; i < cartIds.length; i++) {
        const ok: boolean = await this.updateCartItemChecked(cartIds[i], checked);
        if (ok) successCount++;
      }
      Logger.info(TAG, 'selectAll updated %{public}d / %{public}d items', successCount, cartIds.length);
      return successCount === cartIds.length;
    } catch (e) {
      Logger.error(TAG, 'selectAll error: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  async calculateTotal(userId: string): Promise<number> {
    try {
      const items: CartItem[] = await this.getCartItems(userId);
      let total: number = 0;
      for (let i: number = 0; i < items.length; i++) {
        const item: CartItem = items[i];
        if (item.selected) {
          total = total + (item.price * item.quantity);
        }
      }
      return total;
    } catch (e) {
      Logger.error(TAG, 'calculateTotal error: %{public}s', JSON.stringify(e));
      return 0;
    }
  }
}
