// Chapter 12 demo: @State as the most common data source, with class objects.

class Model {
  public value: string

  constructor(value: string) {
    this.value = value
  }
}

@Entry
@Component
struct StateDemo {
  build() {
    Column() {
      // Pass an initial value (7) to the child's @State count from the parent.
      MyComponent({ count: 7 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct MyComponent {
  @State title: Model = new Model('Hello World')
  @State count: number = 0
  private increaseBy: number = 1

  build() {
    Column({ space: 12 }) {
      Text(`${this.title.value}`)
        .fontSize(20)
        .margin(10)

      Button('Click to change title')
        .onClick(() => {
          // Direct property of a @State class IS observed -> UI refreshes.
          this.title.value = this.title.value === 'Hello ArkUI' ? 'Hello World' : 'Hello ArkUI'
        })
        .width(300)
        .margin(10)

      Button(`Click to increase count = ${this.count}`)
        .onClick(() => {
          this.count += this.increaseBy
        })
        .width(300)
        .margin(10)

      Text('(parent 初始化 count = 7，覆盖本地默认值)')
        .fontSize(12)
        .fontColor('#999')
    }
  }
}
