import { router } from '@kit.ArkUI';

// Chapter 30 landing page: hybrid development with the Web component.
@Entry
@Component
struct Ch30Index {
  build() {
    Column({ space: 16 }) {
      Text('第30篇：Web 组件与混合开发')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('本地 H5 加载 · 生命周期 · ArkTS 与 H5 双向通信 · 请求拦截兜底 · 深色模式与 UA')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('① 加载本地 H5 与生命周期')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch30/BasicWebDemo' } as router.RouterOptions))

      Button('② 双向通信：javaScriptProxy + runJavaScript')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch30/BridgeDemo' } as router.RouterOptions))

      Button('③ 请求拦截与离线兜底')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch30/InterceptDemo' } as router.RouterOptions))

      Button('④ 深色模式 / UA / 缩放（工程配置）')
        .width('85%')
        .backgroundColor('#6A1B9A')
        .onClick(() => router.pushUrl({ url: 'pages/ch30/WebConfigDemo' } as router.RouterOptions))

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
