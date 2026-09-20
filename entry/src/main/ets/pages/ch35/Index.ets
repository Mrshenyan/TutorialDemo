import { router } from '@kit.ArkUI';

// Chapter 35: background audio playback + background download (with completion proxy reminder).
// Both are long-running tasks (continuous task) that keep an ability alive in the background:
//   ① AUDIO_PLAYBACK — AVPlayer keeps playing after the app goes to background
//   ② DATA_TRANSFER  — downloadFile runs in the background, then fires a proxy reminder on completion
// Both require ohos.permission.KEEP_BACKGROUND_RUNNING and the matching EntryAbility.backgroundModes.
@Entry
@Component
struct Ch35Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第35篇：后台音频播放与后台下载')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('把 ch34 的长时任务补齐——后台音频 + 后台下载，下载完成再发一条代理提醒')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        // ---------- ① Background audio ----------
        Text('① 后台音频播放（AUDIO_PLAYBACK）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('后台音频：锁屏控制 + 焦点打断（长时任务 + AVSession）')
          .width('92%')
          .onClick(() => router.pushUrl({ url: 'pages/ch35/AudioPlaybackDemo' } as router.RouterOptions))

        // ---------- ② Background download + reminder ----------
        Text('② 后台下载 + 完成代理提醒（DATA_TRANSFER）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('后台下载：后台传文件，完成发代理提醒（需 dataTransfer）')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch35/DownloadReminderDemo' } as router.RouterOptions))

        Button('返回首页')
          .width('92%')
          .margin({ top: 16 })
          .onClick(() => router.back())
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }
}
