// Chapter 14 demo: @Provide / @Consume syncs across levels by variable name.
@Entry
@Component
struct GrandpaPage {
  // @Provide: must be typed and locally initialized; available to the whole subtree.
  @Provide message: string = '来自祖先的问候'

  build() {
    Column() {
      Text(`祖先 message: ${this.message}`)
        .margin(10)

      Button('祖先改 message')
        .onClick(() => {
          this.message = this.message === '来自祖先的问候' ? '祖先改过了' : '来自祖先的问候'
        })
        .margin(10)

      // Middle layer passes NOTHING.
      MiddleView()
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct MiddleView {
  build() {
    Column() {
      Text('我是中间层，我根本不用 message')
        .margin(10)
      // Still passes nothing down.
      ConsumeChild()
    }
  }
}

@Component
struct ConsumeChild {
  // @Consume: variable name matches the ancestor's @Provide -> auto pair (two-way).
  @Consume message: string

  build() {
    Column() {
      Text(`后代 message: ${this.message}`)
        .margin(10)

      Button('后代改 message')
        .onClick(() => {
          this.message = '后代改过了'
        })
        .margin(10)
    }
  }
}
