import { router } from '@kit.ArkUI'

// Chapter 10 landing page: @Extend to extend a specific component's style.
@Entry
@Component
struct Ch10Index {
  build() {
    Column({ space: 16 }) {
      Text('第10篇：@Extend 扩展组件样式')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('仅全局、针对具体组件类型、可封装私有属性与事件')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('运行 @Extend Demo')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch10/ExtendDemo' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
