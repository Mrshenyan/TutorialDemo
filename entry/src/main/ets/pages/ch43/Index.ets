import { router } from '@kit.ArkUI'

// Chapter 43: service widget (FormKit). The widget itself lives in
// ets/ch43formcard/ and is declared in resources/base/profile/form_config_ch43.json.
@Entry
@Component
struct Ch43Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第43篇：服务卡片（桌面小组件）')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('上一篇扫码是「把外部数据拿进来」，这一篇反过来：把 App 的一角钉到桌面上。卡片不是在 App 里画的，它由系统桌面渲染，所以规则完全不同。')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        Text('① 主应用侧：读写数据 + 主动刷新卡片')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('打开卡片控制台')
          .width('92%')
          .onClick(() => router.pushUrl({ url: 'pages/ch43/Ch43Control' } as router.RouterOptions))

        Text('② 生命周期、三种刷新方式、卡片能力白名单')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('打开速查表')
          .width('92%')
          .backgroundColor('#6A1B9A')
          .onClick(() => router.pushUrl({ url: 'pages/ch43/Ch43Lifecycle' } as router.RouterOptions))

        Text('怎么把卡片放到桌面：先 Build & Install 到设备，然后长按桌面上的应用图标 → 服务卡片 → 选「今日打卡」拖到桌面。第三方应用没有 API 能把卡片塞进桌面，这一步只能由用户完成。')
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
