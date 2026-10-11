import { router } from '@kit.ArkUI'

// Chapter 39: System Notification (NotificationKit).
//   ① Basic text notification — permission + slot type
//   ② Progress notification — downloadTemplate + update by re-publishing the same id
//   ③ WantAgent click — tap notification → deep-link into a specific page (ties back to ch38 Want)
@Entry
@Component
struct Ch39Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第39篇：系统通知 Notification')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('应用如何主动"喊"用户：基础通知 → 进度通知 → 点通知用 Want 跳回页面（接 ch34 后台任务 / ch38 Want）')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        // ---------- ① Basic text notification ----------
        Text('① 基础文本通知（权限 + 通知通道 slot）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('发一条基础通知')
          .width('92%')
          .onClick(() => router.pushUrl({ url: 'pages/ch39/Ch39BasicNotify' } as router.RouterOptions))

        // ---------- ② Progress notification ----------
        Text('② 进度通知（下载模板 + 同 id 更新）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('模拟下载进度通知')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch39/Ch39ProgressNotify' } as router.RouterOptions))

        // ---------- ③ WantAgent click ----------
        Text('③ 点通知跳页面（WantAgent 回接 ch38）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('带点击意图的通知')
          .width('92%')
          .backgroundColor('#6A1B9A')
          .onClick(() => router.pushUrl({ url: 'pages/ch39/Ch39WantAgent' } as router.RouterOptions))

        Button('查看目标页（点通知后到达的页）')
          .width('92%')
          .backgroundColor('#999')
          .margin({ top: 8 })
          .onClick(() => router.pushUrl({ url: 'pages/ch39/Ch39NotifyTarget' } as router.RouterOptions))

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
