import { router } from '@kit.ArkUI';

// Chapter 27 landing page: links to the Canvas basics demo and the
// gesture signature pad demo.
@Entry
@Component
struct Ch27Index {
  build() {
    Column({ space: 16 }) {
      Text('第27篇：手势识别与 Canvas 绘图')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('本章 demo：Canvas 基础 + PanGesture 涂鸦 / 手势签名板（免权限与权限两种保存方式）')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('Canvas 基础 + PanGesture 涂鸦')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch27/CanvasBasic' } as router.RouterOptions))

      Button('手势签名板（保存到相册）')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch27/SignatureDemo' } as router.RouterOptions))

      Button('返回首页')
        .width('80%')
        .margin({ top: 16 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
