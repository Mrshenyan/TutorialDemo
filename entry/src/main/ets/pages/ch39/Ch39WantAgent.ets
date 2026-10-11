import { router } from '@kit.ArkUI'
import { common, Want, wantAgent, WantAgent } from '@kit.AbilityKit'
import { notificationManager } from '@kit.NotificationKit'

interface BizErr { code: number; message: string }

// ③ WantAgent: clicking the notification deep-links into a specific page.
//    The WantAgent carries a Want that EntryAbility reads (notifyTarget) to route — see EntryAbility.ets.
@Entry
@Component
struct Ch39WantAgent {
  @State log: string = '点「发送」后下拉通知栏，点通知 → 应用会被拉起并跳到 ch39 目标页'

  private send(): void {
    // The intent carried by the tap: start the app's EntryAbility and ask it to route to the target page.
    // Strict-mode: build the Record via element assignment (inline literal fails arkts-no-untyped-obj-literals).
    let params: Record<string, Object> = {};
    params['notifyTarget'] = 'pages/ch39/Ch39NotifyTarget'
    const want: Want = {
      bundleName: 'com.cc.tutorialdemo',
      abilityName: 'EntryAbility',
      parameters: params
    }
    const info: wantAgent.WantAgentInfo = {
      wants: [want],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.CONSTANT_FLAG]
    }
    wantAgent.getWantAgent(info).then((agent: WantAgent) => {
      let request: notificationManager.NotificationRequest = {
        id: 3903,
        notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '你有一条新消息',
            text: '点我 → 跳到 ch39 目标页（Want 回接 ch38）',
            additionalText: 'cc'
          }
        },
        wantAgent: agent,
        tapDismissed: true
      }
      notificationManager.publish(request).then(() => {
        this.log = '已发送（id=3903）。现在按 Home 回到桌面，再点通知试试'
      }).catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.log = `发送失败[${be.code}]：${be.message}`
      })
    }).catch((e: BizErr) => {
      const be: BizErr = e as BizErr
      this.log = `WantAgent 创建失败[${be.code}]：${be.message}`
    })
  }

  build() {
    Column({ space: 14 }) {
      Text('③ 点通知跳页面（WantAgent）')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      Text('WantAgent 是"通知的点击意图"：把 ch38 学的 Want 塞进去，点击即拉起 Ability 并带参跳转')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      Button('发送可点击的通知')
        .width('90%')
        .backgroundColor('#6A1B9A')
        .onClick(() => this.send())

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
