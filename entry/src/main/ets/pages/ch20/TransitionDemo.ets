// Chapter 20 §四: transition() — component mount/unmount animation.
// Must pair with if/ForEach AND the state flip must be inside animateTo.

@Entry
@Component
struct TransitionDemo {
  @State show: boolean = false

  build() {
    Column({ space: 20 }) {
      Button(this.show ? '隐藏' : '显示')
        .onClick(() => {
          // The flip MUST be wrapped in animateTo, or transition won't play.
          animateTo({ duration: 400, curve: Curve.Ease }, () => {
            this.show = !this.show
          })
        })

      if (this.show) {
        Text('我出现/消失时会有转场')
          .fontSize(18)
          .padding(16)
          .backgroundColor('#FFE0B2')
          .borderRadius(8)
          .transition(
            TransitionEffect.OPACITY
              .combine(TransitionEffect.scale({ x: 0.5, y: 0.5 }))
          )
      }
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
