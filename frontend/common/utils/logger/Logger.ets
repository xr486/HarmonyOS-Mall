
import hilog from '@ohos.hilog';

const DOMAIN = 0x0000;
const PREFIX = 'HongmenMall';

/**
 * 日志工具类
 */
export class Logger {
  /**
   * 调试日志
   */
  static debug(tag: string, format: string, ...args: any[]): void {
    hilog.debug(DOMAIN, `${PREFIX}[${tag}]`, format, args);
  }

  /**
   * 信息日志
   */
  static info(tag: string, format: string, ...args: any[]): void {
    hilog.info(DOMAIN, `${PREFIX}[${tag}]`, format, args);
  }

  /**
   * 警告日志
   */
  static warn(tag: string, format: string, ...args: any[]): void {
    hilog.warn(DOMAIN, `${PREFIX}[${tag}]`, format, args);
  }

  /**
   * 错误日志
   */
  static error(tag: string, format: string, ...args: any[]): void {
    hilog.error(DOMAIN, `${PREFIX}[${tag}]`, format, args);
  }

  /**
   * fatal 日志
   */
  static fatal(tag: string, format: string, ...args: any[]): void {
    hilog.fatal(DOMAIN, `${PREFIX}[${tag}]`, format, args);
  }
}
