import { router } from '@kit.ArkUI'

// Chapter 6 landing page: @Builder custom build functions.
@Entry
@Component
struct Ch06Index {
  build() {
    Column({ space: 16 }) {
      Text('第6篇：@Builder 自定义构建函数')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('成员 Builder / 全局 Builder / 值传递 vs 引用传递')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('运行 @Builder Demo')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch06/BuilderDemo' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
