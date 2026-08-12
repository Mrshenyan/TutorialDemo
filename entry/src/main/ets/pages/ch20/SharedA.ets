import { router } from '@kit.ArkUI'

// Chapter 20 §五: sharedTransition — Page A (thumbnail).
// The shared id 'heroImg' must match exactly on both pages.

@Entry
@Component
struct SharedA {
  build() {
    Column({ space: 12 }) {
      Image($r('app.media.startIcon'))
        .width(80).height(80).borderRadius(8)
        .sharedTransition('heroImg', { duration: 500, curve: Curve.Ease })

      Button('打开详情')
        .onClick(() => {
          router.pushUrl({ url: 'pages/ch20/SharedB' })
        })
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
