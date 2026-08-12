// Chapter 13 demo: @Prop establishes one-way sync (parent -> child).
@Component
struct PropChild {
  // @Prop is a copy from the parent; child-local change does NOT write back.
  @Prop title: string = '本地默认标题'

  build() {
    Column() {
      Text(`子组件 title: ${this.title}`)
      Button('子组件改 title')
        .onClick(() => {
          this.title = '子组件改过了'
        })
        .margin(10)
    }
  }
}

@Entry
@Component
struct PropDemo {
  @State parentTitle: string = '来自父组件'

  build() {
    Column() {
      Text(`父组件 parentTitle: ${this.parentTitle}`)
        .margin(10)

      Button('父组件改 parentTitle')
        .onClick(() => {
          this.parentTitle = this.parentTitle === '来自父组件' ? '父组件改过了' : '来自父组件'
        })
        .margin(10)

      // Parent -> child: one-way pass (no $).
      PropChild({ title: this.parentTitle })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
