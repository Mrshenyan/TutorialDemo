// Chapter 9 demo: stateStyles switches styles by the component's internal state.
@Entry
@Component
struct StateStylesDemo {
  @State focusedColor: Color = Color.Red
  private normalColor: Color = Color.Green

  // Static @Styles reused inside stateStyles branches.
  @Styles normalStyle() {
    .backgroundColor(Color.Gray)
  }

  @Styles pressedStyle() {
    .backgroundColor(Color.Red)
  }

  build() {
    Column({ space: 16 }) {
      // 1) Basic stateStyles: focus / press / normal.
      Button('Button1')
        .stateStyles({
          focused: { .backgroundColor(Color.Pink) },
          pressed: { .backgroundColor(Color.Black) },
          normal: { .backgroundColor(Color.Red) }
        })
        .margin(10)

      // 2) stateStyles combined with @Styles.
      Text('Text1')
        .fontSize(30)
        .fontColor(Color.White)
        .stateStyles({
          normal: this.normalStyle,
          pressed: this.pressedStyle
        })
        .margin(10)

      // 3) stateStyles referencing a state variable (click to recolor on focus).
      Button('clickMe')
        .height(80)
        .width(120)
        .stateStyles({
          normal: { .backgroundColor(this.normalColor) },
          focused: { .backgroundColor(this.focusedColor) }
        })
        .onClick(() => {
          this.focusedColor = Color.Pink
        })
        .margin(10)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Center)
  }
}
