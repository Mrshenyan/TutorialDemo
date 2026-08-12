import { router } from '@kit.ArkUI'

// Chapter 2 landing page: a visual tour of the HarmonyOS project structure.
@Entry
@Component
struct Ch02Index {
  build() {
    Column({ space: 16 }) {
      Text('第2篇：工程结构速览')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('AppScope / entry / main_pages.json / module.json5 各自负责什么')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('查看工程结构导读')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch02/StructureDemo' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
