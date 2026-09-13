import { router } from '@kit.ArkUI';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

// Demo ②-b (of ch33): request several permissions at once and inspect the granular result.
// Teaches: authResults (granted/denied) AND dialogShownResults (did the system
// actually show a dialog — an already-granted permission won't re-prompt).
const BATCH: Permissions[] = [
  'ohos.permission.CAMERA',
  'ohos.permission.MICROPHONE',
  'ohos.permission.LOCATION'
];

@Entry
@Component
struct Ch33PermMultiPage {
  @State log: string = '点击「一次要三个权限」查看逐项结果';

  async requestBatch(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();
    try {
      const result = await atManager.requestPermissionsFromUser(context, BATCH);
      const lines: string[] = BATCH.map((p: Permissions, i: number) => {
        const granted: boolean = result.authResults[i] === 0;
        const shown: boolean = result.dialogShownResults?result.dialogShownResults[i]:false;
        const state: string = granted ? '允许' : '拒绝';
        const tip: string = shown ? '（弹窗授权）' : '（已记录，未弹窗）';
        return `${p}\n  -> ${state} ${tip}`;
      });
      this.log = lines.join('\n');
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      this.log = `请求异常: ${e.code} ${e.message}`;
    }
  }

  build() {
    Column({ space: 14 }) {
      Text('一次要多个权限')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16 })

      Text('CAMERA / MICROPHONE / LOCATION 同时申请，逐个看结果')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      Button('一次要三个权限')
        .width('80%')
        .backgroundColor('#1565C0')
        .onClick(() => this.requestBatch())

      Text(this.log)
        .fontSize(13)
        .fontColor('#333')
        .width('90%')
        .backgroundColor('#F2F2F2')
        .padding(12)
        .borderRadius(8)

      Text('要点：dialogShownResults=false 表示该权限之前已决定过，' +
        '系统不再弹窗，直接返回历史结果。')
        .fontSize(12)
        .fontColor('#888')
        .width('90%')

      Button('返回')
        .width('80%')
        .margin({ top: 12 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
