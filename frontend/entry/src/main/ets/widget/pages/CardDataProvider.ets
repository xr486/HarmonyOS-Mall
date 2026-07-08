import { HttpUtil, ApiResponse } from '../../common/utils/http/HttpUtil';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'CardDataProvider';

/**
 * 卡片数据提供者 - 使用 AppStorage 全局状态
 * FormExtensionAbility 后台拉取数据写入 AppStorage，卡片页面通过 @StorageProp 读取
 */
export class CardDataProvider {
  private static timerId: number = -1;
  private static readonly DEFAULT_PRODUCTS: string = JSON.stringify([
    { id: '1', name: '手机', price: 2999 },
    { id: '2', name: '耳机', price: 899 },
    { id: '3', name: '平板', price: 3499 },
    { id: '4', name: '手表', price: 1999 }
  ]);

  /**
   * 初始化：设置默认值并启动定时刷新
   */
  static init(): void {
    // 确保 AppStorage 有默认值，避免卡片白屏
    AppStorage.setOrCreate('card_products', CardDataProvider.DEFAULT_PRODUCTS);
    AppStorage.setOrCreate('card_cart_count', 0);
    AppStorage.setOrCreate('card_cart_total', 0);

    // 首次加载真实数据
    CardDataProvider.refresh();
  }

  /**
   * 刷新数据（调用后端API）
   */
  static async refresh(): Promise<void> {
    // 加载商品
    try {
      const res: ApiResponse<Object[]> = await HttpUtil.get('/products?sort=sales&limit=4');
      if (res.code === 200 && res.data) {
        const products: ProductCardItem[] = [];
        for (let i: number = 0; i < res.data.length; i++) {
          const raw: Record<string, Object> = res.data[i] as Record<string, Object>;
          products.push({
            id: (raw['productId'] as string) ?? '',
            name: (raw['name'] as string) ?? '',
            price: (raw['price'] as number) ?? 0
          });
        }
        if (products.length > 0) {
          AppStorage.setOrCreate('card_products', JSON.stringify(products));
          hilog.info(0x0001, TAG, 'Products loaded: %{public}d', products.length);
        }
      }
    } catch (e) {
      hilog.error(0x0001, TAG, 'Product load failed');
    }

    // 加载购物车
    try {
      const res: ApiResponse<Object[]> = await HttpUtil.get('/cart');
      if (res.code === 200 && res.data) {
        let count: number = 0;
        let total: number = 0;
        for (let i: number = 0; i < res.data.length; i++) {
          const raw: Record<string, Object> = res.data[i] as Record<string, Object>;
          count += (raw['quantity'] as number) ?? 0;
          total += ((raw['price'] as number) ?? 0) * ((raw['quantity'] as number) ?? 1);
        }
        AppStorage.setOrCreate('card_cart_count', count);
        AppStorage.setOrCreate('card_cart_total', total);
        hilog.info(0x0001, TAG, 'Cart loaded: count=%{public}d total=%{public}d', count, total);
      }
    } catch (e) {
      // ignore
    }
  }

  /**
   * 启动10秒定时刷新
   */
  static startTimer(): void {
    if (CardDataProvider.timerId !== -1) {
      clearInterval(CardDataProvider.timerId);
    }
    CardDataProvider.timerId = setInterval(() => {
      CardDataProvider.refresh();
    }, 10000);
  }

  /**
   * 停止定时器
   */
  static stopTimer(): void {
    if (CardDataProvider.timerId !== -1) {
      clearInterval(CardDataProvider.timerId);
      CardDataProvider.timerId = -1;
    }
  }
}

interface ProductCardItem {
  id: string;
  name: string;
  price: number;
}
