import http from '@ohos.net.http';
import { Logger } from '../logger/Logger';
import { StorageUtil } from '../storage/StorageUtil';
import { StorageKeys } from '../../constants/StorageKeys';

const TAG = 'HttpUtil';

export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
  timestamp: number;
}

// ==================== 请求体类型 ====================

export class LoginBody {
  phone: string = '';
  code: string = '';
}

export class PasswordLoginBody {
  phone: string = '';
  password: string = '';
}

export class RegisterBody {
  phone: string = '';
  password: string = '';
  code: string = '';
}

export class SendCodeBody {
  phone: string = '';
}

export class AddCartBody {
  productId: string = '';
  productName: string = '';
  productImage: string = '';
  price: number = 0;
  quantity: number = 1;
  specs: string = '';
}

export class UpdateCartBody {
  quantity: number = 1;
}

export class CreateOrderBody {
  totalAmount: number = 0;
  items: Object = new Object();
  address: Object = new Object();
  remark: string = '';
}

export class AddressBody {
  name: string = '';
  phone: string = '';
  province: string = '';
  city: string = '';
  district: string = '';
  detail: string = '';
  isDefault: boolean = false;
}

export class UpdateUserBody {
  nickname: string = '';
}

// ==================== 响应数据类型 ====================

export class LoginResult {
  token: string = '';
  userId: string = '';
  phone: string = '';
  nickname: string = '';
}

export class HttpUtil {
  // 鸿蒙模拟器请改为本机局域网IP（如 192.168.1.100），真机同样用局域网IP
  // localhost 在模拟器中指向模拟器自身，不是宿主机
  private static readonly BASE_URL: string = 'http://10.21.195.5:8080/api/v1';
  private static readonly DEFAULT_TIMEOUT: number = 30000;

  private static async getToken(): Promise<string> {
    return await StorageUtil.getInstance().getString(StorageKeys.USER_TOKEN, '');
  }

  static get<T>(url: string): Promise<ApiResponse<T>> {
    return HttpUtil.request<T>(HttpUtil.BASE_URL + url, http.RequestMethod.GET);
  }

  static post<T>(url: string, data?: Object): Promise<ApiResponse<T>> {
    return HttpUtil.request<T>(HttpUtil.BASE_URL + url, http.RequestMethod.POST, data);
  }

  static put<T>(url: string, data?: Object): Promise<ApiResponse<T>> {
    return HttpUtil.request<T>(HttpUtil.BASE_URL + url, http.RequestMethod.PUT, data);
  }

  static delete<T>(url: string): Promise<ApiResponse<T>> {
    return HttpUtil.request<T>(HttpUtil.BASE_URL + url, http.RequestMethod.DELETE);
  }

  private static async request<T>(
    url: string,
    method: http.RequestMethod,
    data?: Object
  ): Promise<ApiResponse<T>> {
    Logger.debug(TAG, 'Request: %{public}s %{public}s', http.RequestMethod[method], url);

    const httpRequest: http.HttpRequest = http.createHttp();
    const token: string = await HttpUtil.getToken();

    try {
      const header: Record<string, string> = {
        'Content-Type': 'application/json; charset=utf-8'
      };
      if (token) {
        header['Authorization'] = 'Bearer ' + token;
      }

      const response: http.HttpResponse = await httpRequest.request(url, {
        method: method,
        header: header,
        extraData: data ? JSON.stringify(data) : undefined,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: HttpUtil.DEFAULT_TIMEOUT,
        readTimeout: HttpUtil.DEFAULT_TIMEOUT
      });

      Logger.debug(TAG, 'Response status: %{public}d', response.responseCode);

      if (response.responseCode === 200) {
        const result: ApiResponse<T> = JSON.parse(response.result as string) as ApiResponse<T>;
        return result;
      } else {
        const body: string = response.result as string;
        Logger.error(TAG, 'HTTP error %{public}d: %{public}s', response.responseCode, body);
        const errorResult: ApiResponse<T> = {
          code: response.responseCode,
          message: body,
          data: null as T,
          timestamp: Date.now()
        };
        return errorResult;
      }
    } catch (error) {
      const errMsg: string = error instanceof Error ? error.message : JSON.stringify(error);
      Logger.error(TAG, 'Request failed: %{public}s', errMsg);
      const errorResult: ApiResponse<T> = {
        code: 500,
        message: errMsg,
        data: null as T,
        timestamp: Date.now()
      };
      return errorResult;
    } finally {
      httpRequest.destroy();
    }
  }
}
