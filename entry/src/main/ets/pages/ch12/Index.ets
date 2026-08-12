import { router } from '@kit.ArkUI'

// Chapter 12 landing page: the @State decorator in depth.
@Entry
@Component
struct Ch12Index {
  build() {
    Column({ space: 16 }) {
      Text('第12篇：@State 装饰器')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('私有数据源、需类型与初值、简单类型直接观察、对象属性亦可')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('运行 @State Demo')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch12/StateDemo' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
