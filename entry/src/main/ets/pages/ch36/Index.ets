import { router } from '@kit.ArkUI';

// Chapter 36: RCP (Remote Communication Kit) advanced networking.
// RCP is the recommended networking stack over the legacy http module:
//   ① Basics    — Session + get/fetch, headers, response handling
//   ② Interceptor — chain interceptors to inject auth headers, log, retry on 5xx
//   ③ Advanced  — timeout, resumable download (transferRange), SSL certificate pinning
// All demos require ohos.permission.INTERNET in module.json5.
@Entry
@Component
struct Ch36Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第36篇：网络 RCP 进阶')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('从「跑通」到「工程化」：Session 复用、拦截器链、超时 / 断点续传 / 证书锁定')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        // ---------- ① Basics ----------
        Text('① 基础请求（GET / POST）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('基础：session.get / fetch + Request 设请求头')
          .width('92%')
          .onClick(() => router.pushUrl({ url: 'pages/ch36/Ch36RcpBasicDemo' } as router.RouterOptions))

        // ---------- ② Interceptor ----------
        Text('② 拦截器（鉴权 / 日志 / 重试）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('拦截器：自动加 token、打日志、5xx 重试')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch36/Ch36RcpInterceptorDemo' } as router.RouterOptions))

        // ---------- ③ Advanced ----------
        Text('③ 高级配置（超时 / 续传 / 证书锁定）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('高级：transfer.timeout / transferRange / certificatePinning')
          .width('92%')
          .backgroundColor('#6A1B9A')
          .onClick(() => router.pushUrl({ url: 'pages/ch36/Ch36RcpAdvancedDemo' } as router.RouterOptions))

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
