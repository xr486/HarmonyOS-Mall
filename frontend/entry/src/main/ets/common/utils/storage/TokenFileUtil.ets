import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { util } from '@kit.ArkTS';

const TOKEN_FILE_NAME = 'user_token.txt';

/**
 * 跨进程 Token 文件存储工具
 * UIAbility 和 FormExtensionAbility 运行在不同进程，Preferences 不共享，
 * 使用应用 filesDir 下的文件可实现跨进程读取。
 */
export class TokenFileUtil {

  private static getFilePath(context: common.Context): string {
    const appCtx = context.getApplicationContext();
    return appCtx.filesDir + '/' + TOKEN_FILE_NAME;
  }

  /**
   * 保存 Token 到文件
   */
  static saveToken(context: common.Context, token: string): void {
    try {
      const path: string = TokenFileUtil.getFilePath(context);
      const file: fs.File = fs.openSync(path, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
      const encoder = new util.TextEncoder();
      const buffer: ArrayBuffer = encoder.encodeInto(token);
      fs.writeSync(file.fd, buffer);
      fs.closeSync(file);
    } catch (e) {
      // ignore
    }
  }

  /**
   * 从文件读取 Token
   */
  static readToken(context: common.Context): string {
    try {
      const path: string = TokenFileUtil.getFilePath(context);
      if (fs.accessSync(path)) {
        const file: fs.File = fs.openSync(path, fs.OpenMode.READ_ONLY);
        const stat: fs.Stat = fs.statSync(path);
        const buffer: ArrayBuffer = new ArrayBuffer(stat.size);
        fs.readSync(file.fd, buffer);
        fs.closeSync(file);
        const decoder = new util.TextDecoder('utf-8');
        return decoder.decodeWithStream(new Uint8Array(buffer));
      }
    } catch (e) {
      // ignore
    }
    return '';
  }

  /**
   * 清除 Token 文件
   */
  static clearToken(context: common.Context): void {
    try {
      const path: string = TokenFileUtil.getFilePath(context);
      if (fs.accessSync(path)) {
        fs.unlinkSync(path);
      }
    } catch (e) {
      // ignore
    }
  }
}
