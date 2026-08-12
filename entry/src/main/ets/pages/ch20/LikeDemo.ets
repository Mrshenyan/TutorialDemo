// Chapter 20 §七: a like animation — pop the heart (scale up then back).

@Entry
@Component
struct LikeDemo {
  @State liked: boolean = false
  @State scaleVal: number = 1

  build() {
    Column() {
      Text(this.liked ? '❤️' : '🤍')
        .fontSize(64)
        .scale({ x: this.scaleVal, y: this.scaleVal })
        .onClick(() => {
          this.liked = !this.liked
          // Pop up to 1.4, then back to 1 — the classic "bounce" feel.
          animateTo({ duration: 120, curve: Curve.Linear }, () => {
            this.scaleVal = 1.4
          })
          setTimeout(() => {
            animateTo({ duration: 180, curve: Curve.Linear }, () => {
              this.scaleVal = 1
            })
          }, 120)
        })
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
