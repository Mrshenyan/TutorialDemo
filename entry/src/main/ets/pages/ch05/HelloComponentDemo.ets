// Chapter 5 demo: a reusable custom component driven by a state variable.
// @Component defines a custom component; @State makes `message` refresh the UI on change.
@Entry
@Component
struct HelloComponentDemo {
  @State message: string = 'HelloComponent'

  build() {
    // A custom component composes system components (Row + Text).
    Row() {
      Text(this.message)
        .fontSize(30)
        .onClick(() => {
          // State change drives UI refresh: 'HelloComponent' -> 'Hello, ArkUI!'
          this.message = 'Hello, ArkUI!'
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
