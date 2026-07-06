const ORDER_REFRESH_KEY = 'orderRefreshTrigger';

AppStorage.setOrCreate<number>(ORDER_REFRESH_KEY, 0);

export class OrderRefreshUtil {
  static trigger(): void {
    const current: number = (AppStorage.get<number>(ORDER_REFRESH_KEY) as number) ?? 0;
    AppStorage.setOrCreate<number>(ORDER_REFRESH_KEY, current + 1);
  }

  static getKey(): string {
    return ORDER_REFRESH_KEY;
  }
}
