import { router } from '@kit.ArkUI'

// Chapter 13 landing page: @Prop (one-way) and @Link (two-way) between parent and child.
@Entry
@Component
struct Ch13Index {
  build() {
    Column({ space: 16 }) {
      Text('第13篇：@Prop 与 @Link')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('Prop 父子单向 / Link 父子双向（传 $ 引用）')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('@Prop 单向同步')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch13/PropDemo' }))

      Button('@Link 双向同步')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch13/LinkDemo' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
