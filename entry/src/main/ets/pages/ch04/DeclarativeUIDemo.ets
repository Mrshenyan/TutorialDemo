// Chapter 4 demo: declarative UI description with attributes and event methods.
@Entry
@Component
struct DeclarativeUIDemo {
  @State message: string = 'Hello World'

  build() {
    Column({ space: 16 }) {
      // 1) Component creation + parameter: Text receives the state variable as a parameter.
      Text(this.message)
        .fontSize(50)
        .fontColor(Color.Red)
        .fontWeight(FontWeight.Bold)
        // 2) Event method: reassign the state -> UI refreshes automatically.
        .onClick(() => {
          this.message = '你点到我了'
        })

      Divider()

      // 3) Container component holds children (Row -> Text items).
      Row({ space: 12 }) {
        Text('item 1')
        Text('item 2')
      }

      Button('重置文案')
        .onClick(() => {
          this.message = 'Hello World'
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Center)
  }
}
