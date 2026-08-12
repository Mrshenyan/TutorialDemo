// Chapter 19 §五: bindPopup — a lightweight bubble attached to a component.

@Entry
@Component
struct PopupDemo {
  @State showTip: boolean = false
  @State showCustom: boolean = false

  @Builder
  popupBuilder() {
    Column() {
      Text('自定义气泡').fontSize(14)
      Button('知道了').onClick(() => { this.showCustom = false })
    }
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }

  build() {
    Column({ space: 24 }) {
      Button('点我（文字气泡）')
        .onClick(() => { this.showTip = !this.showTip })
        .bindPopup(this.showTip, {
          message: '这是一条气泡提示',
          placement: Placement.Bottom,
          showInSubWindow: false,
          onStateChange: (e) => {
            if (!e.isVisible) { this.showTip = false }
          }
        })

      Button('点我（自定义气泡）')
        .onClick(() => { this.showCustom = !this.showCustom })
        .bindPopup(this.showCustom, {
          builder: this.popupBuilder,
          placement: Placement.Top,
          mask: true,
          onStateChange: (e) => { if (!e.isVisible) { this.showCustom = false } }
        })
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center)
  }
}
