import { router } from '@kit.ArkUI';
import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';

// Demo ③: publish a proxy reminder. The reminder is held by the system reminder service,
// so it fires even if the app is killed. Needs ohos.permission.PUBLISH_AGENT_REMINDER.
@Entry
@Component
struct Ch34ReminderDemo {
  @State log: string = '尚未发布提醒';
  private reminderId: number = -1;

  // Wipe ALL of this app's reminders in one shot. Used both before publishing a new
  // one (so we never accumulate toward the 30-reminder system limit that throws
  // 1700002) and by the emergency "clear all" button. cancelAllReminders() needs
  // no reminderId, so it sidesteps the ReminderRequest-has-no-reminderId typing trap.
  private async clearAllReminders(): Promise<void> {
    try {
      await reminderAgentManager.cancelAllReminders();
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      // 1700003 = nothing to cancel; safe to ignore.
      if (e.code !== 1700003) {
        console.error(`cancelAllReminders failed: ${e.code} ${e.message}`);
        return ; // surface the real failure so callers report it instead of faking success
      }
    }
  }

  async publishTimer(): Promise<void> {
    const timer: reminderAgentManager.ReminderRequestTimer = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
      triggerTimeInSeconds: 10,
      title: '该休息啦',
      content: '站起来伸个懒腰，喝口水～',
      actionButton: [
        { title: '知道了', type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE }
      ]
    };
    try {
      // Start from a clean slate: clear every leftover reminder before publishing,
      // so repeated taps (and old stuck reminders from earlier runs) can never push
      // us past the 30-reminder system limit.
      await this.clearAllReminders();
      this.reminderId = await reminderAgentManager.publishReminder(timer);
      this.log = `已发布倒计时提醒（10 秒后触发），reminderId=${this.reminderId}。切到后台也能收到。`;
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      if (e.code === 1700002) {
        this.log = '发布失败 1700002：提醒数量超出限制。' +
          '① 先点「清空全部提醒」再发；' +
          '② 若清空后仍报，多半是应用未开通「代理提醒使用权限」——普通应用默认可用额度为 0，需向华为申请开通，此时发 1 条也超 0 额度。';
      } else if (e.code === 1700001) {
        this.log = '发布失败 1700001：通知使能未开启，请在系统设置开启本应用通知，或代码中调用 Notification.requestEnableNotification()。';
      } else if (e.code === 1700004) {
        this.log = '发布失败 1700004：包名不存在（应用未安装/包名不匹配），请重新运行安装本应用。';
      } else {
        this.log = `发布失败: ${e.code} ${e.message}`;
      }
    }
  }

  // Emergency button: revoke every reminder of this app at once.
  async clearAll(): Promise<void> {
    try {
      await this.clearAllReminders();
      this.reminderId = -1;
      this.log = '已清空本应用全部提醒。';
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      this.log = `清空失败: ${e.code} ${e.message}（若为 1700004，多为应用未正确安装/包名不匹配，请重装应用）。`;
    }
  }

  async cancel(): Promise<void> {
    if (this.reminderId < 0) {
      this.log = '当前没有已发布的提醒';
      return;
    }
    try {
      await reminderAgentManager.cancelReminder(this.reminderId);
      this.reminderId = -1;
      this.log = '已取消提醒。';
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      this.log = `取消失败: ${e.code} ${e.message}`;
    }
  }

  build() {
    Column({ space: 14 }) {
      Text('代理提醒（Proxy Reminder）')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16 })

      Text('提醒由系统提醒服务托管，到点弹通知，应用被杀也能响。反复点"发布"会累积，超过 30 条上限会报 1700002。')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      Button('10 秒后提醒我（倒计时提醒）')
        .width('80%')
        .backgroundColor('#2E7D32')
        .onClick(() => this.publishTimer())

      Button('取消提醒')
        .width('80%')
        .backgroundColor('#C62828')
        .onClick(() => this.cancel())

      Button('清空全部提醒（应急）')
        .width('80%')
        .backgroundColor('#F57C00')
        .onClick(() => this.clearAll())

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
