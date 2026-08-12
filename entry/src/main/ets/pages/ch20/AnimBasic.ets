// Chapter 20 §二: animation() — implicit property animation.
// animation() only affects properties declared BEFORE it.

@Entry
@Component
struct AnimBasic {
  @State boxWidth: number = 100
  @State angle: number = 0
  private timer: number = 0

  aboutToAppear(): void {
    // Infinite rotation demo (clear on destroy to avoid leak).
    this.timer = setInterval(() => { this.angle += 30 }, 1000)
  }

  aboutToDisappear(): void {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = 0
    }
  }

  build() {
    Column({ space: 32 }) {
      Button('变宽')
        .onClick(() => {
          this.boxWidth = this.boxWidth === 100 ? 200 : 100
        })

      Column() {
        Text('我会被动画')
      }
      .width(this.boxWidth)           // ① changing property
      .height(this.boxWidth)
      .backgroundColor(Color.Orange)
      .borderRadius(12)
      .animation({                   // ② animation AFTER the properties it animates
        duration: 500,
        curve: Curve.EaseInOut
      })

      // Loading spinner: rotation driven by @State + interval.
      Image($r('app.media.startIcon'))
        .width(48)
        .height(48)
        .rotate({ angle: this.angle })
        .animation({ duration: 1000, iterations: -1, playMode: PlayMode.Normal })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
