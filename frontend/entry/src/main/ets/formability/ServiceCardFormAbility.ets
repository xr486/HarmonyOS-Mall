import { formBindingData, FormExtensionAbility } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CardDataProvider } from '../widget/pages/CardDataProvider';
import { StorageUtil } from '../common/utils/storage/StorageUtil';

const TAG = 'ServiceCardFormAbility';

/**
 * 服务卡片 FormExtensionAbility
 * 初始化 CardDataProvider（写入 AppStorage 默认数据），启动10秒刷新定时器
 * 卡片页面通过 @StorageProp 从 AppStorage 读取实时数据
 */
export default class ServiceCardFormAbility extends FormExtensionAbility {

  onCreate(want: Want): formBindingData.FormBindingData {
    hilog.info(0x0001, TAG, 'ServiceCardFormAbility onCreate');

    try {
      StorageUtil.getInstance().init(this.context.getApplicationContext());
    } catch (e) {
      // ignore
    }

    // 写入默认数据并启动后台刷新
    CardDataProvider.init();
    CardDataProvider.startTimer();

    return formBindingData.createFormBindingData({});
  }

  onUpdateForm(formId: string): void {
    hilog.info(0x0001, TAG, `onUpdateForm formId=${formId}`);
  }

  onFormEvent(formId: string, message: string): void {
    hilog.info(0x0001, TAG, `onFormEvent formId=${formId} message=${message}`);
  }

  onCastToNormal(formId: string): void {
    hilog.info(0x0001, TAG, `onCastToNormal formId=${formId}`);
  }

  onDestroy(): void {
    CardDataProvider.stopTimer();
    hilog.info(0x0001, TAG, 'ServiceCardFormAbility onDestroy');
  }
}
