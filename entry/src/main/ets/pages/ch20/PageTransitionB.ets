import { router } from '@kit.ArkUI'

// Chapter 20 §六: pageTransition() — Page B counterpart.

@Entry
@Component
struct PageTransitionB {
  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 300, curve: Curve.Ease })
      .slide(SlideEffect.Right)
      .opacity(0)

    PageTransitionExit({ type: RouteType.Push, duration: 300 })
      .slide(SlideEffect.Left)
      .opacity(0)
  }

  build() {
    Column() {
      Text('页面 B').fontSize(24)
      Button('返回').onClick(() => router.back())
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
