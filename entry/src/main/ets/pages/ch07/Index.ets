import { router } from '@kit.ArkUI'

// Chapter 7 landing page: @BuilderParam (pass a builder into a child as a slot).
@Entry
@Component
struct Ch07Index {
  build() {
    Column({ space: 16 }) {
      Text('第7篇：@BuilderParam 构建参数')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('把构建函数当参数传入子组件（类似插槽 / 尾随闭包）')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('运行 @BuilderParam Demo')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch07/BuilderParamDemo' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
