import { router } from '@kit.ArkUI';

// Chapter 33 (combined): closes three loose ends left by ch31 (AVPlayer) and ch32 (AVRecorder):
//   ① 媒体库落地   — photoAccessHelper: pick from / save into the system album
//   ② 权限实战     — user_grant permission, end to end
//   ③ 状态管理三件套 — @Watch / PersistentStorage / Environment
@Entry
@Component
struct Ch33Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第33篇：媒体闭环三连击')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('媒体库落地 · 权限实战 · 状态管理三件套（一篇补齐 ch31/32 的收尾）')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        // ---------- ① 媒体库落地 ----------
        Text('① 媒体库落地（相册 / 媒体库）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('从相册挑选图片/视频并预览（PhotoViewPicker，免权限）')
          .width('92%')
          .onClick(() => router.pushUrl({ url: 'pages/ch33/PickerPage' } as router.RouterOptions))

        Button('把当前页面截图存进系统相册（componentSnapshot + 存库，免权限）')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch33/SaveSnapshotPage' } as router.RouterOptions))

        // ---------- ② 权限实战 ----------
        Text('② 权限实战（user_grant 全链路）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('运行时请求权限 + 被拒引导去设置页')
          .width('92%')
          .onClick(() => router.pushUrl({ url: 'pages/ch33/PermRequestPage' } as router.RouterOptions))

        Button('一次要多个权限 + 逐项看结果')
          .width('92%')
          .backgroundColor('#1565C0')
          .onClick(() => router.pushUrl({ url: 'pages/ch33/PermMultiPage' } as router.RouterOptions))

        // ---------- ③ 状态管理三件套 ----------
        Text('③ 状态管理收尾三件套')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('@Watch：状态一变就执行副作用')
          .width('92%')
          .onClick(() => router.pushUrl({ url: 'pages/ch33/WatchDemo' } as router.RouterOptions))

        Button('PersistentStorage：杀进程后还在')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch33/PersistDemo' } as router.RouterOptions))

        Button('Environment：读系统深色/字号（只读）')
          .width('92%')
          .backgroundColor('#1565C0')
          .onClick(() => router.pushUrl({ url: 'pages/ch33/EnvDemo' } as router.RouterOptions))

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
