import { router } from '@kit.ArkUI';
import { common, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';

// Demo ①: start / stop a long-running (continuous) task.
// Prerequisites (declared in module.json5, see the article):
//   - requestPermissions: ohos.permission.KEEP_BACKGROUND_RUNNING
//   - the EntryAbility declares "backgroundModes": ["location"]
@Entry
@Component
struct Ch34LongTaskDemo {
  @State log: string = '尚未申请长时任务';
  @State running: boolean = false;

  async startTask(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    // WantAgent is shown on the persistent notification; tapping it returns to this ability.
    try {
      const agent = await wantAgent.getWantAgent({
        wants: [
          {
            bundleName: context.abilityInfo.bundleName,
            abilityName: 'EntryAbility'
          }
        ],
        actionType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0
      });
      await backgroundTaskManager.startBackgroundRunning(
        context,
        backgroundTaskManager.BackgroundMode.LOCATION,
        agent
      );
      this.running = true;
      this.log = '已申请长时任务（LOCATION）。状态栏会出现一条常驻通知。';
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      this.log = `申请失败: ${e.code} ${e.message}`;
    }
  }

  async stopTask(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    try {
      await backgroundTaskManager.stopBackgroundRunning(context);
      this.running = false;
      this.log = '已停止长时任务，常驻通知消失。';
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      this.log = `停止失败: ${e.code} ${e.message}`;
    }
  }

  build() {
    Column({ space: 14 }) {
      Text('长时任务（Continuous Task）')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16 })

      Text('让 Ability 在后台持续运行（常用于后台定位 / 音频 / 下载）。')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      Button(this.running ? '停止长时任务' : '申请长时任务')
        .width('80%')
        .backgroundColor(this.running ? '#C62828' : '#2E7D32')
        .onClick(() => {
          if (this.running) {
            this.stopTask();
          } else {
            this.startTask();
          }
        })

      Text(this.log)
        .fontSize(14)
        .fontColor('#333')
        .width('90%')
        .backgroundColor('#F2F2F2')
        .padding(12)
        .borderRadius(8)

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
