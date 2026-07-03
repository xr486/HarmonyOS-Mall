
/**
 * 路由常量定义
 */
export class RouteConstants {
  // 首页
  static readonly HOME = 'pages/HomePage';
  
  // 商品相关
  static readonly PRODUCT_LIST = 'pages/ProductDetailPage';
  static readonly PRODUCT_DETAIL = 'pages/ProductDetailPage';
  static readonly CATEGORY = 'pages/ProductDetailPage';
  static readonly SEARCH = 'pages/ProductDetailPage';
  
  // 购物车
  static readonly CART = 'pages/CartPage';
  
  // 订单相关
  static readonly ORDER_CONFIRM = 'pages/OrderListPage';
  static readonly ORDER_LIST = 'pages/OrderListPage';
  static readonly ORDER_DETAIL = 'pages/OrderListPage';
  
  // 用户相关
  static readonly LOGIN = 'pages/Login';
  static readonly REGISTER = 'pages/Register';
  static readonly USER_CENTER = 'pages/UserCenterPage';
  static readonly USER_INFO = 'pages/UserInfo';
  static readonly ADDRESS_LIST = 'pages/AddressList';
  static readonly ADDRESS_EDIT = 'pages/AddressEdit';
  
  // 其他
  static readonly SETTINGS = 'pages/Settings';
  static readonly ABOUT = 'pages/About';
}
