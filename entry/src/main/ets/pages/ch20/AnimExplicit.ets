// Chapter 20 §三: animateTo() — explicit (imperative) animation.
// Wrap "state changes" in the closure; all changes animate together.

@Entry
@Component
struct AnimExplicit {
  @State w: number = 100
  @State boxOpacity: number = 1

  build() {
    Column({ space: 20 }) {
      Button('一次性联动')
        .onClick(() => {
          animateTo({ duration: 600, curve: Curve.Ease }, () => {
            this.w = this.w === 100 ? 220 : 100
            this.boxOpacity = this.boxOpacity === 1 ? 0.3 : 1
          })
        })

      Column() {
        Text('宽和透明度一起动')
      }
      .width(this.w)
      .height(this.w)
      .opacity(this.boxOpacity)
      .backgroundColor(Color.Blue)
      .borderRadius(12)
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
