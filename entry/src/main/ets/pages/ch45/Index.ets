import { router } from '@kit.ArkUI'

// Chapter 45 landing page: logging and online issue location.
// The through-line: hilog is for you-with-hdc, a private file is for
// you-without-hdc, hiAppEvent is for the system telling you what broke.
@Entry
@Component
struct Ch45Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第45篇：日志与线上问题定位')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('上一篇 App 能把数据送出去了，这一篇关心「出事之后怎么办」。hilog 分级打印、私有目录落盘、hiAppEvent 打点与系统故障订阅，三层各司其职。')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        Text('① hilog 分级打印与隐私占位符')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('hilog 演示')
          .width('92%')
          .onClick(() => router.pushUrl({ url: 'pages/ch45/Ch45Hilog' } as router.RouterOptions))

        Text('② 日志落盘：App 私有目录（el2）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('文件日志演示')
          .width('92%')
          .backgroundColor('#00838F')
          .onClick(() => router.pushUrl({ url: 'pages/ch45/Ch45FileLog' } as router.RouterOptions))

        Text('③ hiAppEvent 打点与系统事件订阅')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('hiAppEvent 演示')
          .width('92%')
          .backgroundColor('#6A1B9A')
          .onClick(() => router.pushUrl({ url: 'pages/ch45/Ch45AppEvent' } as router.RouterOptions))

        Text('环境提示：hilog 需配合 hdc 查看（hdc shell "hilog"）；模拟崩溃会杀掉进程，属预期行为，重启后进 ③ 号页面即可收到 APP_CRASH 事件。')
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
