import { router } from '@kit.ArkUI';

// Chapter 28 landing page: links to the three advanced-gesture demos.
@Entry
@Component
struct Ch28Index {
  build() {
    Column({ space: 16 }) {
      Text('第28篇：手势识别的高级用法')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('组合手势（顺序 / 并行 / 互斥）、手势优先级、缩放手势实战')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('① 可缩放 / 旋转 / 拖拽的图片查看器')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch28/ImageViewer' } as router.RouterOptions))

      Button('② 手势优先级演示（父容器 vs 子视图）')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch28/GesturePriorityDemo' } as router.RouterOptions))

      Button('③ 组合手势三兄弟（Sequence / Parallel / Exclusive）')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch28/CombinedModesDemo' } as router.RouterOptions))

      Button('返回首页')
        .width('85%')
        .margin({ top: 16 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
