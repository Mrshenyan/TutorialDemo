import { router } from '@kit.ArkUI';
import { abilityAccessCtrl, common, Permissions, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

// Demo ②-a (of ch33): request a user_grant permission at runtime, then guide the
// user to the system settings page when permanently denied.
const PERMS: Permissions[] = [
  'ohos.permission.CAMERA',
  'ohos.permission.MICROPHONE'
];

@Entry
@Component
struct Ch33PermRequestPage {
  @State results: string = '尚未请求';
  @State granted: boolean = false;

  // Core: AtManager.requestPermissionsFromUser(context, permissions[]).
  async request(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();
    try {
      const result = await atManager.requestPermissionsFromUser(context, PERMS);
      // authResults: 0 = granted, other = denied. One entry per requested permission.
      const allGranted: boolean = result.authResults.every((r: number) => r === 0);
      this.granted = allGranted;
      this.results = PERMS
        .map((p: Permissions, i: number) => `${p} => ${result.authResults[i] === 0 ? '允许' : '拒绝'}`)
        .join('\n');
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      this.results = `请求异常: ${e.code} ${e.message}`;
    }
  }

  // When denied, jump to the app's settings page so the user can toggle manually.
  openSettings(): void {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const want: Want = {
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',
      uri: 'application_info_entry',
      parameters: {
        pushParams: context.abilityInfo.bundleName
      }
    };
    context.startAbility(want).catch(() => {});
  }

  build() {
    Column({ space: 14 }) {
      Text('运行时请求 + 设权引导')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16 })

      Text('本页请求 CAMERA 与 MICROPHONE 两个权限')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      Button('请求权限')
        .width('80%')
        .onClick(() => this.request())

      Text(this.results)
        .fontSize(14)
        .fontColor('#333')
        .width('90%')
        .backgroundColor('#F2F2F2')
        .padding(12)
        .borderRadius(8)

      if (this.granted) {
        Text('✅ 已全部授权，可以干活了')
          .fontSize(15)
          .fontColor('#2E7D32')
      } else {
        Button('去系统设置页手动开启')
          .width('80%')
          .backgroundColor('#C62828')
          .onClick(() => this.openSettings())
      }

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
