import hilog from '@ohos.hilog';

const DOMAIN = 0x0000;
const PREFIX = 'HongmenMall';

export class Logger {
  static debug(tag: string, format: string, ...args: Object[]): void {
    hilog.debug(DOMAIN, `${PREFIX}[${tag}]`, format, args);
  }

  static info(tag: string, format: string, ...args: Object[]): void {
    hilog.info(DOMAIN, `${PREFIX}[${tag}]`, format, args);
  }

  static warn(tag: string, format: string, ...args: Object[]): void {
    hilog.warn(DOMAIN, `${PREFIX}[${tag}]`, format, args);
  }

  static error(tag: string, format: string, ...args: Object[]): void {
    hilog.error(DOMAIN, `${PREFIX}[${tag}]`, format, args);
  }

  static fatal(tag: string, format: string, ...args: Object[]): void {
    hilog.fatal(DOMAIN, `${PREFIX}[${tag}]`, format, args);
  }
}
