// Chapter 8 demo: @Styles reuses a chain of common attribute/event methods.

// Global @Styles: app-wide, NO parameters allowed.
@Styles function globalFancy() {
  .width(150)
  .height(100)
  .backgroundColor(Color.Pink)
}

@Entry
@Component
struct StylesDemo {
  @State heightValue: number = 100

  // Component-level @Styles: same name as global -> component one wins (higher priority).
  @Styles fancy() {
    .width(200)
    .height(this.heightValue)
    .backgroundColor(Color.Yellow)
    .onClick(() => {
      this.heightValue = 200
    })
  }

  build() {
    Column({ space: 16 }) {
      Text('FancyA（全局 @Styles）').fontSize(16)
      Text('FancyA')
        .globalFancy()
        .fontSize(20)

      Text('FancyB（组件内 @Styles，点击变高）').fontSize(16)
      Text('FancyB')
        .fancy()
        .fontSize(20)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Center)
  }
}
