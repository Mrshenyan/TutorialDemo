import { router } from '@kit.ArkUI';

// Chapter 31 landing page: multimedia playback with AVPlayer.
@Entry
@Component
struct Ch31Index {
  build() {
    Column({ space: 16 }) {
      Text('第31篇：AVPlayer 多媒体播放')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('声明式 Video 组件 · AVPlayer 状态机 · XComponent 渲染视频 · 纯音频播放 · 进度/音量/倍速')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('① 声明式 Video 组件（开箱即用）')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch31/VideoPlayerPage' } as router.RouterOptions))

      Button('② AVPlayer + XComponent（自定义视频播放器）')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch31/AVPlayerPage' } as router.RouterOptions))

      Button('③ AVPlayer 纯音频播放')
        .width('85%')
        .backgroundColor('#2E7D32')
        .onClick(() => router.pushUrl({ url: 'pages/ch31/AudioPlayerPage' } as router.RouterOptions))

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
