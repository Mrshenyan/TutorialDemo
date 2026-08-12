import { router } from '@kit.ArkUI'

// Chapter 22 landing page: links to the two Preferences demos.
@Entry
@Component
struct Ch22Index {
  build() {
    Column({ space: 16 }) {
      Text('第22篇：数据持久化 Preferences')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('本章 demo：轻量级 KV 存储 Preferences 的读写与变更订阅')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('基础读写：增删改查')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch22/PrefsBasic' }))

      Button('数据变更订阅：on change')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch22/PrefsObserve' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
