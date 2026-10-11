import { router } from '@kit.ArkUI'

// Target page reached when the user taps the notification from Ch39WantAgent.
// EntryAbility reads the `notifyTarget` Want parameter and loadContent()s this page.
@Entry
@Component
struct Ch39NotifyTarget {
  build() {
    Column({ space: 16 }) {
      Text('🎯 ch39 目标页')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      Text('你是通过「点通知」用 Want 跳过来的！')
        .fontSize(15)
        .fontColor('#317af7')
        .width('90%')
        .textAlign(TextAlign.Center)

      Text('这条链路把三篇串起来了：\nch34 后台任务完成 → ch39 发通知 → ch38 的 Want 拉起指定页面')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')
        .textAlign(TextAlign.Center)

      Button('返回首页')
        .width('90%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Center)
  }
}
