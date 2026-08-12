import { router } from '@kit.ArkUI'

// Chapter 8 landing page: @Styles for reusing style chains.
@Entry
@Component
struct Ch08Index {
  build() {
    Column({ space: 16 }) {
      Text('第8篇：@Styles 样式复用')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('全局 / 组件内样式，组件内优先级更高；不支持传参')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('运行 @Styles Demo')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch08/StylesDemo' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
