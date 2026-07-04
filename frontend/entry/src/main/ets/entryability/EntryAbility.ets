import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import type AbilityConstant from '@ohos.app.ability.AbilityConstant';
import type Want from '@ohos.app.ability.Want';
import { initialize } from '@hw-agconnect/hmcore';
import type { JsonTypeInfo } from '@hw-agconnect/hmcore';
import { util } from '@kit.ArkTS';
<<<<<<< Updated upstream
import { DatabaseHelper } from '../database/helper';
import { DataInitializer } from '../database/DataInitializer';
import { AuthManager } from '../services/auth/AuthManager';
=======
import { DatabaseHelper } from '../database/helper/DatabaseHelper';
import { StorageUtil } from '../common/utils/storage/StorageUtil';
import { LocationManager } from '../common/utils';
>>>>>>> Stashed changes

export default class EntryAbility extends UIAbility {
  private agcInitPromise: Promise<void> | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.info('[EntryAbility] onCreate');

    AppStorage.setOrCreate('abilityContext', this.context);
    AppStorage.setOrCreate('uiAbilityContext', this.context);

<<<<<<< Updated upstream
=======
    StorageUtil.getInstance().init(this.context);
    LocationManager.getInstance().init(this.context);

>>>>>>> Stashed changes
    this.agcInitPromise = this.initAGC();
  }

  private async initAGC(): Promise<void> {
    try {
      const rawData: Uint8Array = await this.context.resourceManager.getRawFileContent('agconnect-services.json');
      const textDecoder: util.TextDecoder = util.TextDecoder.create('utf-8');
      const jsonStr: string = textDecoder.decodeWithStream(rawData);
      const jsonObj: JsonTypeInfo = JSON.parse(jsonStr) as JsonTypeInfo;
      initialize(this.context, jsonObj);

      AuthManager.getInstance().init();
      console.info('[EntryAbility] AGC initialized');
    } catch (error) {
      console.error('[EntryAbility] Failed to init AGC:', (error as Error).message);
    }
  }

  onDestroy(): void {
    console.info('[EntryAbility] onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    console.info('[EntryAbility] onWindowStageCreate');

    windowStage.loadContent('pages/Index', async (err) => {
      if (err.code) {
        console.error(`Failed to load content. Code: ${err.code}, message: ${err.message}`);
        return;
      }

      if (this.agcInitPromise) {
        console.info('[EntryAbility] Waiting for AGC init...');
        await this.agcInitPromise;
      }
      DatabaseHelper.getInstance().init();
      await DataInitializer.getInstance().initTestData();
      console.info('Succeeded in loading content.');
    });
  }

  onWindowStageDestroy(): void {
    console.info('[EntryAbility] onWindowStageDestroy');
  }

  onForeground(): void {
    console.info('[EntryAbility] onForeground');
  }

  onBackground(): void {
    console.info('[EntryAbility] onBackground');
  }
}
