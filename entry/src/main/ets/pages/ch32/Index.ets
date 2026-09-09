import { router } from '@kit.ArkUI';

// Chapter 32 landing page: AVRecorder from basics to advanced.
@Entry
@Component
struct Ch32Index {
  build() {
    Column({ space: 16 }) {
      Text('第32篇：AVRecorder 音视频录制')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('从“消费媒体”到“生产媒体”：播放是 ch31，录制是这一篇')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 8 })

      // ---- 基础：麦克风录音 + 相机录像 ----
      Text('基础篇')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#317af7')
        .width('85%')
        .textAlign(TextAlign.Start)

      Button('① 麦克风录音 + 回放（纯音频）')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch32/AudioRecordPage' } as router.RouterOptions))

      Button('② 相机录像（AVRecorder 视频链路）')
        .width('85%')
        .backgroundColor('#2E7D32')
        .onClick(() => router.pushUrl({ url: 'pages/ch32/VideoRecordPage' } as router.RouterOptions))

      // ---- 进阶：参数精调 / 实时音量条 / 转码 ----
      Text('进阶篇')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#317af7')
        .width('85%')
        .textAlign(TextAlign.Start)
        .margin({ top: 8 })

      Button('③ 参数精调体系（档位 / 横竖屏 / aacProfile）')
        .width('85%')
        .backgroundColor('#1565C0')
        .onClick(() => router.pushUrl({ url: 'pages/ch32/AudioTunerPage' } as router.RouterOptions))

      Button('④ 实时麦克风音量条（AudioCapturer）')
        .width('85%')
        .backgroundColor('#1565C0')
        .onClick(() => router.pushUrl({ url: 'pages/ch32/VolumeMeterPage' } as router.RouterOptions))

      Button('⑤ 录制后转码（AVTranscoder）')
        .width('85%')
        .backgroundColor('#1565C0')
        .onClick(() => router.pushUrl({ url: 'pages/ch32/TranscodePage' } as router.RouterOptions))

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
