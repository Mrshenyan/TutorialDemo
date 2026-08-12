import { router } from '@kit.ArkUI'

// Chapter 20 §五: sharedTransition — Page B (big image).
// Same id 'heroImg' as Page A; a real page jump triggers the flight.

@Entry
@Component
struct SharedB {
  build() {
    Column() {
      Image($r('app.media.startIcon'))
        .width(300).height(300).borderRadius(16)
        .sharedTransition('heroImg', { duration: 500, curve: Curve.Ease })

      Button('返回')
        .margin({ top: 20 })
        .onClick(() => { router.back() })
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
