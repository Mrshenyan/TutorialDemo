import { router } from '@kit.ArkUI'

// Chapter 21 landing page: links to the two network demos.
@Entry
@Component
struct Ch21Index {
  build() {
    Column({ space: 16 }) {
      Text('第21篇：网络数据请求')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('本章 demo：http 模块 与 RCP 两套请求方式')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('http 模块：拉取文章列表')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch21/NetDemo' }))

      Button('RCP：现代通信框架')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch21/RcpDemo' }))

      Button('查询参数 & 鉴权 Header')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch21/QueryAuthDemo' }))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
