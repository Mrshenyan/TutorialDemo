import { router } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'
import { notificationManager } from '@kit.NotificationKit'

interface BizErr { code: number; message: string }

// ① Basic text notification: request permission (if needed), pick a slot type, then publish.
@Entry
@Component
struct Ch39BasicNotify {
  @State log: string = '点「发送」前会先检查通知权限；若未授权会弹系统授权框'
  @State slotType: notificationManager.SlotType = notificationManager.SlotType.SERVICE_INFORMATION
  @State slotLabel: string = 'SERVICE_INFORMATION（服务消息：横幅 + 提示音）'

  // Check permission first; prompt the system dialog only when needed, then publish.
  private ensurePermissionAndPublish(): void {
    const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    notificationManager.isNotificationEnabled().then((enabled: boolean) => {
      if (enabled) {
        this.doPublish()
        return
      }
      notificationManager.requestEnableNotification(ctx).then(() => {
        this.doPublish()
      }).catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.log = `授权失败[${be.code}]：${be.message}`
      })
    }).catch((e: BizErr) => {
      const be: BizErr = e as BizErr
      this.log = `检查权限失败[${be.code}]：${be.message}`
    })
  }

  private doPublish(): void {
    let request: notificationManager.NotificationRequest = {
      id: 3901,
      // Slot type decides how "loud" the notification is. Since API 11 prefer `notificationSlotType`.
      notificationSlotType: this.slotType,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: '下载完成',
          text: '《鸿蒙零基础教程》第39篇已更新',
          additionalText: 'cc 的专栏'
        }
      },
      // Auto-remove the notification when the user taps it.
      tapDismissed: true
    }
    notificationManager.publish(request).then(() => {
      this.log = `已发送（id=3901，slot=${this.slotLabel}）。下拉通知栏即可看到`
    }).catch((e: BizErr) => {
      const be: BizErr = e as BizErr
      this.log = `发送失败[${be.code}]：${be.message}`
    })
  }

  private cancel(): void {
    notificationManager.cancel(3901).then(() => {
      this.log = '已取消 id=3901 的通知'
    }).catch((e: BizErr) => {
      const be: BizErr = e as BizErr
      this.log = `取消失败[${be.code}]：${be.message}`
    })
  }

  build() {
    Column({ space: 14 }) {
      Text('① 基础文本通知')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      Text('先确认通知权限，再选择 slot（通知通道）类型，最后 publish')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      // Slot type picker.
      Row({ space: 8 }) {
        Button('社交')
          .backgroundColor(this.slotType === notificationManager.SlotType.SOCIAL_COMMUNICATION ? '#317af7' : '#ccc')
          .onClick(() => {
            this.slotType = notificationManager.SlotType.SOCIAL_COMMUNICATION
            this.slotLabel = 'SOCIAL_COMMUNICATION（社交通知：强提醒）'
          })
        Button('服务')
          .backgroundColor(this.slotType === notificationManager.SlotType.SERVICE_INFORMATION ? '#317af7' : '#ccc')
          .onClick(() => {
            this.slotType = notificationManager.SlotType.SERVICE_INFORMATION
            this.slotLabel = 'SERVICE_INFORMATION（服务消息：横幅 + 提示音）'
          })
        Button('内容')
          .backgroundColor(this.slotType === notificationManager.SlotType.CONTENT_INFORMATION ? '#317af7' : '#ccc')
          .onClick(() => {
            this.slotType = notificationManager.SlotType.CONTENT_INFORMATION
            this.slotLabel = 'CONTENT_INFORMATION（内容推荐：弱提醒）'
          })
      }
      .width('90%')

      Text(this.slotLabel)
        .fontSize(12)
        .fontColor('#888')
        .width('90%')

      Button('发送基础通知')
        .width('90%')
        .backgroundColor('#317af7')
        .onClick(() => this.ensurePermissionAndPublish())

      Button('取消这条通知')
        .width('90%')
        .backgroundColor('#999')
        .onClick(() => this.cancel())

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
