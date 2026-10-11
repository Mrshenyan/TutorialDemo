import { router } from '@kit.ArkUI'
import { notificationManager } from '@kit.NotificationKit'

interface BizErr { code: number; message: string }

// ② Progress notification: use the built-in downloadTemplate and re-publish the SAME id to update.
@Entry
@Component
struct Ch39ProgressNotify {
  @State progress: number = 0
  @State log: string = '点「开始下载」模拟后台下载，通知栏会实时刷新进度'
  private timer: number = -1

  // Re-publishing the same id UPDATES the existing notification instead of stacking new ones.
  private publishProgress(pct: number): void {
    const tpl: notificationManager.NotificationTemplate = {
      name: 'downloadTemplate',
      data: {
        title: '正在下载《鸿蒙零基础教程》',
        fileName: 'ch39_demo.mp4',
        progressValue: pct
      }
    }
    let request: notificationManager.NotificationRequest = {
      id: 3902,
      notificationSlotType: notificationManager.SlotType.SERVICE_INFORMATION,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: '下载中',
          text: `进度 ${pct}%`,
          additionalText: 'cc'
        }
      },
      template: tpl,
      tapDismissed: false
    }
    notificationManager.publish(request).catch((e: BizErr) => {
      const be: BizErr = e as BizErr
      this.log = `更新失败[${be.code}]：${be.message}`
    })
  }

  private start(): void {
    if (this.timer !== -1) {
      return
    }
    this.progress = 0
    this.publishProgress(0)
    // Use a timer to simulate incremental download progress.
    this.timer = setInterval(() => {
      this.progress += 5
      if (this.progress >= 100) {
        this.progress = 100
        this.finish()
        return
      }
      this.publishProgress(this.progress)
    }, 400) as number
  }

  private finish(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer)
      this.timer = -1
    }
    // Final "completed" notification reuses id 3902 → updates the same card in place.
    let done: notificationManager.NotificationRequest = {
      id: 3902,
      notificationSlotType: notificationManager.SlotType.SERVICE_INFORMATION,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: '下载完成 ✅',
          text: 'ch39_demo.mp4 已就绪',
          additionalText: 'cc'
        }
      },
      tapDismissed: true
    }
    notificationManager.publish(done).then(() => {
      this.log = '下载完成，通知已更新为"完成"状态'
    }).catch((e: BizErr) => {
      const be: BizErr = e as BizErr
      this.log = `完成通知失败[${be.code}]：${be.message}`
    })
  }

  private cancelAll(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer)
      this.timer = -1
    }
    notificationManager.cancel(3902).then(() => {
      this.log = '已取消 id=3902 进度通知'
    }).catch((e: BizErr) => {
      const be: BizErr = e as BizErr
      this.log = `取消失败[${be.code}]：${be.message}`
    })
  }

  aboutToDisappear(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer)
      this.timer = -1
    }
  }

  build() {
    Column({ space: 14 }) {
      Text('② 进度通知（下载模板）')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      Text('用 downloadTemplate + 重复 publish 同一 id 实现"进度刷新"，避免刷出一堆通知')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      Text(`当前进度：${this.progress}%`)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)

      Button('开始下载')
        .width('90%')
        .backgroundColor('#2E7D32')
        .onClick(() => this.start())

      Button('取消下载')
        .width('90%')
        .backgroundColor('#999')
        .onClick(() => this.cancelAll())

      Text(this.log)
        .fontSize(13)
        .fontColor('#444')
        .width('90%')
        .fontFamily('monospace')

      Button('返回')
        .width('90%')
        .margin({ top: 8 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Start)
  }
}
