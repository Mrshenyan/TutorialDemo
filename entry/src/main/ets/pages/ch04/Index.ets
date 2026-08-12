import { router } from '@kit.ArkUI'

// Chapter 4 landing page: ArkTS language & declarative UI.
@Entry
@Component
struct Ch04Index {
  build() {
    Column({ space: 16 }) {
      Text('第4篇：ArkTS 语言与声明式 UI')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('声明式描述 UI：组件创建、属性方法、事件方法')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('运行声明式 UI Demo')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch04/DeclarativeUIDemo' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
