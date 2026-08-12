import { router } from '@kit.ArkUI'

// Chapter 14 landing page: @Provide / @Consume for cross-level two-way sync.
@Entry
@Component
struct Ch14Index {
  build() {
    Column({ space: 16 }) {
      Text('第14篇：@Provide 与 @Consume')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('跨层级双向同步，按变量名/别名自动配对，中间层免传参')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('按变量名配对')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch14/ProvideConsumeDemo' }))

      Button('按别名配对')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch14/AliasDemo' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
