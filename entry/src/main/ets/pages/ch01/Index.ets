import { router } from '@kit.ArkUI'

// Chapter 1 landing page: Hello World & project structure overview.
@Entry
@Component
struct Ch01Index {
  build() {
    Column({ space: 16 }) {
      Text('第1篇：Hello World 与工程结构')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('从 Empty Ability + Stage 模型开始，跑通第一个 Hello World')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('运行 Hello World Demo')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch01/HelloWorldDemo' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
