// Chapter 19 §4.1-§4.3: CustomDialog + CustomDialogController.
// IMPORTANT (ArkUI pitfall): do NOT use @Link through the controller — it
// breaks in many versions. Use a callback / onChange to pass data back.

// 4.1 minimal custom layout; controller auto-injected.
@CustomDialog
struct TipDialog {
  controller?: CustomDialogController
  msg: string = ''

  build() {
    Column() {
      Text(this.msg).fontSize(18).margin({ bottom: 16 })
      Button('关闭').onClick(() => this.controller?.close())
    }
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}

// 4.3 posture A: return result via a callback property.
@CustomDialog
struct InputDialog {
  controller?: CustomDialogController
  @State text: string = ''
  onConfirm?: (value: string) => void

  build() {
    Column() {
      TextInput({ placeholder: '请输入', text: this.text })
        .onChange((v) => { this.text = v })
      Button('确定')
        .margin({ top: 12 })
        .onClick(() => {
          this.onConfirm?.(this.text)
          this.controller?.close()
        })
    }
    .padding(24)
  }
}

// 4.3 posture B: live two-way sync via onChange callback (NOT @Link).
@CustomDialog
struct LinkDialog {
  controller?: CustomDialogController
  value: string = ''
  onChange?: (v: string) => void

  build() {
    Column() {
      TextInput({ text: this.value })
        .onChange((v) => {
          this.value = v
          this.onChange?.(v) // local display + notify page live
        })
      Button('关闭').onClick(() => this.controller?.close())
    }
    .padding(24)
  }
}

@Entry
@Component
struct CustomDemo {
  @State result: string = ''
  @State name: string = 'cc'

  // Keep controllers as plain properties (NOT @State).
  tipController: CustomDialogController = new CustomDialogController({
    builder: TipDialog({ msg: '这是一个自定义弹窗' }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    maskColor: 'rgba(0,0,0,0.4)'
  })

  inputController!: CustomDialogController
  linkController: CustomDialogController = new CustomDialogController({
    builder: LinkDialog({
      value: this.name,
      onChange: (v: string) => { this.name = v } // live sync back to page
    })
  })

  aboutToAppear(): void {
    // Re-new the controller in aboutToAppear to capture the latest state.
    this.inputController = new CustomDialogController({
      builder: InputDialog({
        onConfirm: (v: string) => { this.result = v }
      })
    })
  }

  build() {
    Column({ space: 16 }) {
      Text(`输入结果：${this.result}`).fontSize(18)
      Text(`实时同步：${this.name}`).fontSize(18)

      Button('打开提示弹窗').onClick(() => this.tipController.open())
      Button('输入点东西').onClick(() => this.inputController.open())
      Button('双向同步（回调）').onClick(() => this.linkController.open())
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center)
  }
}
