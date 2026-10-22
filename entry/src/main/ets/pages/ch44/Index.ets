import { router } from '@kit.ArkUI'

// Chapter 44: system share (ShareKit, HMS side) + clipboard.
// ShareKit needs HMS Core; the share panel itself is a system UI, so the app
// never draws it. Clipboard lives in BasicServicesKit and is pure OpenHarmony.
@Entry
@Component
struct Ch44Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第44篇：系统分享与剪贴板')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('上一篇把 App 钉到桌面，这一篇把内容送出去。分享面板、剪贴板都是系统级 UI，我们要做的只是把数据按正确格式交出去。')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        Text('① 分享文本 / 链接（ShareController.show）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('打开文本分享')
          .width('92%')
          .onClick(() => router.pushUrl({ url: 'pages/ch44/Ch44ShareText' } as router.RouterOptions))

        Text('② 分享图片（PixelMap → 文件 → URI）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('打开图片分享')
          .width('92%')
          .backgroundColor('#00838F')
          .onClick(() => router.pushUrl({ url: 'pages/ch44/Ch44ShareImage' } as router.RouterOptions))

        Text('③ 剪贴板读写 + 零权限复制')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('打开剪贴板演示')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch44/Ch44Clipboard' } as router.RouterOptions))

        Text('环境提示：ShareKit 属于 HMS 侧能力，需要设备带 HMS Core；模拟器若拉不起分享面板，换真机验证。剪贴板与 copyOption 在模拟器上完全可用。')
          .fontSize(12)
          .fontColor('#888')
          .width('92%')
          .margin({ top: 10 })

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
