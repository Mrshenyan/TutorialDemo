import { router } from '@kit.ArkUI'

// Chapter 38: Inter-ability / cross-app navigation with Want.
//   ① Implicit Want  — launch system apps (browser / dialer / settings)
//   ② Explicit Want  — start a 2nd UIAbility in the same app, pass parameters
//   ③ startAbilityForResult — start + receive a result back from the target
@Entry
@Component
struct Ch38Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第38篇：应用间跳转 Want')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('Want 是鸿蒙的"意图"对象：显式精确点名，隐式交给系统匹配；还能带参、能要回执')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        // ---------- ① Implicit Want ----------
        Text('① 隐式 Want（拉起系统应用）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('浏览器 / 拨号 / 设置')
          .width('92%')
          .onClick(() => router.pushUrl({ url: 'pages/ch38/Ch38ImplicitSystem' } as router.RouterOptions))

        // ---------- ② Explicit Want ----------
        Text('② 显式 Want（同应用跳 Ability + 传参）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('启动 Ch38TargetAbility 并传参')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch38/Ch38ExplicitSameApp' } as router.RouterOptions))

        // ---------- ③ startAbilityForResult ----------
        Text('③ startAbilityForResult（带回执）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('启动并接收回传结果')
          .width('92%')
          .backgroundColor('#6A1B9A')
          .onClick(() => router.pushUrl({ url: 'pages/ch38/Ch38ResultBack' } as router.RouterOptions))

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
