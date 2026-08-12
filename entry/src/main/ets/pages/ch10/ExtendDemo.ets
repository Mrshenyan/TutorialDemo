// Chapter 10 demo: @Extend wraps a specific component's style chain (global only).

// @Extend targets Text, can take parameters, and can call other @Extend methods.
@Extend(Text) function fancyText(weightValue: number, color: Color) {
  .fontStyle(FontStyle.Italic)
  .fontWeight(weightValue)
  .backgroundColor(color)
}

@Entry
@Component
struct ExtendDemo {
  @State label: string = 'Hello World'

  build() {
    Row({ space: 10 }) {
      Text(`${this.label}`).fancyText(100, Color.Blue)
      Text(`${this.label}`).fancyText(200, Color.Pink)
      Text(`${this.label}`).fancyText(300, Color.Orange)
    }
    .margin(20)
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}
