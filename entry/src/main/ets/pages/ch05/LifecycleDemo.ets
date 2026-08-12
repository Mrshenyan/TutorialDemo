// Chapter 5 demo: component lifecycle and conditional rendering (mount / unmount a child).
@Entry
@Component
struct LifecycleDemo {
  @State showChild: boolean = true
  @State log: string = 'aboutToAppear: 组件即将出现'

  // Runs after the instance is created, before build(). Safe to initialize state here.
  aboutToAppear(): void {
    this.log = 'aboutToAppear: 组件即将出现'
  }

  // Page-level lifecycle (only valid on @Entry components).
  onPageShow(): void {
    this.log = 'onPageShow: 页面已显示'
  }

  onPageHide(): void {
    this.log = 'onPageHide: 页面已隐藏'
  }

  // NOTE: do NOT mutate state inside aboutToDisappear (framework behavior becomes unstable).

  build() {
    Column({ space: 12 }) {
      Text(this.log)
        .fontSize(13)
        .fontColor('#38761D')
        .margin(8)

      // Conditional render: child is created when true, destroyed when false.
      if (this.showChild) {
        LifecycleChild()
      }

      Button('delete Child')
        .onClick(() => {
          this.showChild = false
        })

      Button('restore Child')
        .onClick(() => {
          this.showChild = true
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}

@Component
struct LifecycleChild {
  @State title: string = 'Hello World'

  aboutToAppear(): void {
    // Child mounted: nothing to display here, just a hook point.
  }

  aboutToDisappear(): void {
    // Child will be removed; do not mutate state here.
  }

  build() {
    Text(this.title)
      .fontSize(40)
      .onClick(() => {
        this.title = 'Hello ArkUI'
      })
      .margin(10)
  }
}
