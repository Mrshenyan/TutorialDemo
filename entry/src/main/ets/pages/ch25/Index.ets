import { router } from '@kit.ArkUI';

// Chapter 25 landing page: links to the three application-level state demos.
@Entry
@Component
struct Ch25Index {
  build() {
    Column({ space: 16 }) {
      Text('第25篇：应用级状态管理')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('本章 demo：AppStorage 全局状态 / AppStorage 页面级状态 / Environment 设备环境')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('AppStorage：全局状态')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch25/AppStorageDemo' } as router.RouterOptions))

      Button('LocalStorage：页面级状态')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch25/LocalStorageDemo' } as router.RouterOptions))

      Button('Environment：设备环境')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch25/EnvironmentDemo' } as router.RouterOptions))

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
