import { router } from '@kit.ArkUI'

// Chapter 3 landing page: the Stage model concept (AbilityStage / UIAbility / WindowStage / Context).
@Entry
@Component
struct Ch03Index {
  build() {
    Column({ space: 16 }) {
      Text('第3篇：Stage 模型核心概念')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('UIAbility 生命周期与四层结构，日常开发聚焦 UIAbility')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('查看 Stage 模型图示')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch03/StageModelDemo' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
