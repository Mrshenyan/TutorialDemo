import { router } from '@kit.ArkUI'

// Chapter 9 landing page: stateStyles (polymorphic styles by component state).
@Entry
@Component
struct Ch09Index {
  build() {
    Column({ space: 16 }) {
      Text('第9篇：stateStyles 动态样式')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('按 focused / pressed / normal / disabled 切换样式')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('运行 stateStyles Demo')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch09/StateStylesDemo' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
