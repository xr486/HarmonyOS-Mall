/**
 * 收藏数据模型
 */
export interface FavoriteItem {
  favoriteId: string;
  favoritedAt: number;
  productId: string;
  name: string;
  price: number;
  images: string[];
  rating: number;
  salesCount: number;
}
