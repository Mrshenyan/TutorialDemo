import { router } from '@kit.ArkUI';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';

// Demo ②: borrow a short grace period before the system suspends the app.
// No permission and no module config required — perfect for "save draft / flush cache" work.
@Entry
@Component
struct Ch34DelayTaskDemo {
  @State log: string = '尚未申请延时任务';
  private requestId: number = 0;

  requestDelay(): void {
    // The callback fires when the grace period ends and the app is about to be suspended.
    const info: backgroundTaskManager.DelaySuspendInfo =
      backgroundTaskManager.requestSuspendDelay('保存草稿并上传', () => {
        // App is about to be frozen — do the last bit of synchronous work here (time is short).
        this.log = '宽限期结束，系统即将挂起应用。';
      });
    this.requestId = info.requestId;
    this.log = `已申请延时任务：requestId=${info.requestId}，实际宽限时长=${info.actualDelayTime}ms`;
  }

  async queryRemaining(): Promise<void> {
    try {
      const remain: number = await backgroundTaskManager.getRemainingDelayTime(this.requestId);
      this.log = `剩余宽限时间：${remain}ms`;
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      this.log = `查询失败: ${e.code} ${e.message}`;
    }
  }

  cancelDelay(): void {
    if (this.requestId === 0) {
      this.log = '当前没有进行中的延时任务';
      return;
    }
    backgroundTaskManager.cancelSuspendDelay(this.requestId);
    this.requestId = 0;
    this.log = '已取消延时任务。';
  }

  build() {
    Column({ space: 14 }) {
      Text('延时任务（Transient / Suspend Delay）')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16 })

      Text('系统要挂起应用前，向系统借一段短宽限期（通常几十秒~几分钟，按配额），用于收尾工作。')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      Button('申请延时任务')
        .width('80%')
        .onClick(() => this.requestDelay())

      Button('查询剩余宽限时间')
        .width('80%')
        .backgroundColor('#2E7D32')
        .onClick(() => this.queryRemaining())

      Button('取消延时任务')
        .width('80%')
        .backgroundColor('#1565C0')
        .onClick(() => this.cancelDelay())

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
