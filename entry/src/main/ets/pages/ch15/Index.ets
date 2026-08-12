import { router } from '@kit.ArkUI'

// Chapter 15 landing page: Observed + ObjectLink demos.
@Entry
@Component
struct Ch15Index {
  build() {
    Column({ space: 16 }) {
      Text('第15篇：Observed 与 ObjectLink')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('嵌套对象 / 对象数组的深层属性变化如何驱动 UI 刷新')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('嵌套对象观察（Observed + ObjectLink）')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch15/ObservedDemo' }))

      Button('Map / 内置类型观察（@Observed extends）')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch15/MapDemo' }))

      Button('返回首页')
        .width('85%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
