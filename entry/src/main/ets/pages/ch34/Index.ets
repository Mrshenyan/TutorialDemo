import { router } from '@kit.ArkUI';

// Chapter 34: background tasks and proxy reminders.
// Three independent capabilities are covered:
//   ① Long-running task (continuous task) — keep an ability alive in the background
//      (needs ohos.permission.KEEP_BACKGROUND_RUNNING + ability "continuingType")
//   ② Transient task (suspend delay) — borrow a short grace period before the system suspends the app (no permission)
//   ③ Proxy reminder — schedule a notification that fires even if the app is killed
//      (needs ohos.permission.PUBLISH_AGENT_REMINDER)
@Entry
@Component
struct Ch34Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第34篇：后台任务与代理提醒')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('长时任务保活 · 延时任务省电 · 代理提醒免后台（三种后台能力一次讲清）')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        // ---------- ① Long-running task ----------
        Text('① 长时任务（Continuous Task）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('长时任务：申请/停止后台保活（需 KEEP_BACKGROUND_RUNNING + continuingType）')
          .width('92%')
          .onClick(() => router.pushUrl({ url: 'pages/ch34/LongTaskDemo' } as router.RouterOptions))

        // ---------- ② Transient / suspend delay ----------
        Text('② 延时任务（Transient / Suspend Delay）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('延时任务：挂起前借一段宽限期（无需权限）')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch34/DelayTaskDemo' } as router.RouterOptions))

        // ---------- ③ Proxy reminder ----------
        Text('③ 代理提醒（Proxy Reminder）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('代理提醒：定时/倒计时通知（需 PUBLISH_AGENT_REMINDER）')
          .width('92%')
          .backgroundColor('#1565C0')
          .onClick(() => router.pushUrl({ url: 'pages/ch34/ReminderDemo' } as router.RouterOptions))

        Button('返回首页')
          .width('92%')
          .margin({ top: 16 })
          .onClick(() => router.back())
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }
}
