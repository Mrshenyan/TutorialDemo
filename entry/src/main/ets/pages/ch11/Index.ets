import { router } from '@kit.ArkUI'

// Chapter 11 landing page: state management overview (@State vs regular variable).
@Entry
@Component
struct Ch11Index {
  build() {
    Column({ space: 16 }) {
      Text('第11篇：状态管理入门')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('@State 状态变量变化驱动 UI 刷新；普通变量不会')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('运行状态管理 Demo')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch11/StateMgmtDemo' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
