import { router } from '@kit.ArkUI'

// Chapter 5 landing page: custom components & basic syntax (lifecycle, conditional render).
@Entry
@Component
struct Ch05Index {
  build() {
    Column({ space: 16 }) {
      Text('第5篇：自定义组件与基础语法')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('@Component / @Entry / build / 生命周期 / 条件渲染')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('自定义组件 HelloComponent')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch05/HelloComponentDemo' }))

      Button('组件生命周期演示')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch05/LifecycleDemo' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
