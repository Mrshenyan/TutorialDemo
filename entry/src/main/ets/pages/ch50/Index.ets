import { router } from '@kit.ArkUI'

// Chapter 50 landing page: AppStartup.
// Order: read the config, look at the real timeline, then meet manual mode and
// the cost of blocking the UI thread.
@Entry
@Component
struct Ch50Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第50篇：应用启动优化——AppStartup 启动框架')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('冷启动那几百毫秒，一半是初始化任务在排队。这一篇把初始化从 UIAbility.onCreate 里搬出来，交给启动框架按依赖关系并发调度，再用应用自己打的点证明它真的快在哪儿。')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        Text('① 配置：四个零件')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('看 startup_config.json 怎么写')
          .width('92%')
          .backgroundColor('#1565C0')
          .onClick(() => router.pushUrl({ url: 'pages/ch50/Ch50Overview' } as router.RouterOptions))

        Text('② 实测：这次冷启动的时间线')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('六个时间点，一条一条对')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch50/Ch50Timeline' } as router.RouterOptions))

        Text('③ 延迟：不该跑的就别跑')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('手动模式：点一次才初始化')
          .width('92%')
          .backgroundColor('#6A1B9A')
          .onClick(() => router.pushUrl({ url: 'pages/ch50/Ch50Manual' } as router.RouterOptions))

        Text('④ 代价：主线程被占住是什么感觉')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('让心跳停 900 毫秒给你看')
          .width('92%')
          .backgroundColor('#C62828')
          .onClick(() => router.pushUrl({ url: 'pages/ch50/Ch50Perf' } as router.RouterOptions))

        Text('本章需要改动 module.json5（srcEntry + appStartup）和 resources/base/profile/startup_config.json。改完必须重新安装一次，配置在安装时就被解析了。')
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
