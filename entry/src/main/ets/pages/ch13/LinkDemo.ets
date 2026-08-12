// Chapter 13 demo: @Link establishes two-way sync (parent <-> child) via $.
@Component
struct CounterChild {
  // @Link: NO local default; must be passed from parent with $.
  @Link count: number

  build() {
    Column() {
      Text(`子组件 count: ${this.count}`)
      Button('子组件 +1')
        .onClick(() => {
          this.count++
        })
        .margin(10)
    }
  }
}

@Entry
@Component
struct LinkDemo {
  @State count: number = 0

  build() {
    Column() {
      Text(`父组件 count: ${this.count}`)
        .margin(10)

      Button('父组件 +1')
        .onClick(() => {
          this.count++
        })
        .margin(10)

      // Two-way binding: pass the reference with $count.
      CounterChild({ count: $count })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
