import { router } from '@kit.ArkUI'

// Chapter 20 §六: pageTransition() — whole-page enter/exit (peer of build()).
// Used with router.pushUrl; for Navigation use its custom transition instead.

@Entry
@Component
struct PageTransitionA {
  // pageTransition is a method at the @Component level, parallel to build().
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
      Text('页面 A').fontSize(24)
      Button('去 B').onClick(() => router.pushUrl({ url: 'pages/ch20/PageTransitionB' }))
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
