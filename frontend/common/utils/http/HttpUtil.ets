import http from '@ohos.net.http';
import { Logger } from '../logger/Logger';

const TAG = 'HttpUtil';

export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
  timestamp: number;
}

export class HttpUtil {
  private static readonly BASE_URL = 'https://api.hongmen-mall.example.com/v1';
  private static readonly DEFAULT_TIMEOUT = 30000;

  static async get<T>(url: string, params?: Record<string, any>): Promise<ApiResponse<T>> {
    let fullUrl = `${this.BASE_URL}${url}`;
    if (params) {
      const queryString = Object.entries(params)
        .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
        .join('&');
      fullUrl += `?${queryString}`;
    }

    return this.request<T>(fullUrl, http.RequestMethod.GET);
  }

  static async post<T>(url: string, data?: Record<string, any>): Promise<ApiResponse<T>> {
    const fullUrl = `${this.BASE_URL}${url}`;
    return this.request<T>(fullUrl, http.RequestMethod.POST, data);
  }

  static async put<T>(url: string, data?: Record<string, any>): Promise<ApiResponse<T>> {
    const fullUrl = `${this.BASE_URL}${url}`;
    return this.request<T>(fullUrl, http.RequestMethod.PUT, data);
  }

  static async delete<T>(url: string): Promise<ApiResponse<T>> {
    const fullUrl = `${this.BASE_URL}${url}`;
    return this.request<T>(fullUrl, http.RequestMethod.DELETE);
  }

  private static async request<T>(
    url: string,
    method: http.RequestMethod,
    data?: Record<string, any>
  ): Promise<ApiResponse<T>> {
    Logger.debug(TAG, 'Request: %{public}s %{public}s', http.RequestMethod[method], url);

    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(url, {
        method: method,
        header: {
          'Content-Type': 'application/json; charset=utf-8'
        },
        extraData: data ? JSON.stringify(data) : undefined,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: this.DEFAULT_TIMEOUT,
        readTimeout: this.DEFAULT_TIMEOUT
      });

      Logger.debug(TAG, 'Response status: %{public}d', response.responseCode);

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as ApiResponse<T>;
        return result;
      } else {
        throw new Error(`HTTP error: ${response.responseCode}`);
      }
    } catch (error) {
      Logger.error(TAG, 'Request failed: %{public}s', JSON.stringify(error));
      throw error;
    } finally {
      httpRequest.destroy();
    }
  }
}
