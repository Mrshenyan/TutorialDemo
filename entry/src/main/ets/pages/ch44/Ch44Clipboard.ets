import { router } from '@kit.ArkUI'
import { pasteboard } from '@kit.BasicServicesKit'

interface BizErr { code: number; message: string }

// Chapter 44 - clipboard. Two very different things live here:
//   1. pasteboard: programmatic read/write of the *system* clipboard.
//      Reading it triggers the system "允许粘贴" prompt on API 11+, because a
//      silent read would be a privacy hole. There is no permission to request
//      that skips the prompt.
//   2. Text().copyOption(CopyOptions.InApp): the user long-presses and copies
//      within your own app. Zero permission, zero prompt - use this whenever
//      the goal is just "let the user copy this text".
@Entry
@Component
struct Ch44Clipboard {
  @State input: string = '跟着cc一起学鸿蒙开发 · 第44篇'
  @State clipText: string = '（还没读取）'
  @State log: string = '还没操作'
  @State hasClip: boolean = false

  private write(): void {
    const data: pasteboard.PasteData =
      pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.input)
    pasteboard.getSystemPasteboard().setData(data)
      .then(() => {
        this.log = '已写入系统剪贴板（切到别的 App 长按就能粘贴）'
        this.refreshState()
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.log = `写入失败 [${be.code}] ${be.message}`
      })
  }

  private read(): void {
    pasteboard.getSystemPasteboard().getData()
      .then((d: pasteboard.PasteData) => {
        this.clipText = d.getPrimaryText()
        this.log = `读取成功 · mime=${d.getPrimaryMimeType()}`
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        // The user can refuse the system paste prompt; that path lands here too,
        // so phrase it as a status rather than a red error.
        this.log = `读取失败 [${be.code}] ${be.message}`
      })
  }

  private refreshState(): void {
    pasteboard.getSystemPasteboard().hasData()
      .then((ok: boolean) => {
        this.hasClip = ok
      })
      .catch(() => {
        this.hasClip = false
      })
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('③ 剪贴板：写入、读取、以及「别乱读」')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 12 })

        Text('剪贴板是全局资源。写入随时可以，读取会弹系统提示——这是设计，不是 bug。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        TextInput({ text: this.input })
          .width('100%')
          .onChange((v: string) => this.input = v)

        Row() {
          Button('写入剪贴板')
            .layoutWeight(1)
            .onClick(() => this.write())
          Button('读取剪贴板')
            .layoutWeight(1)
            .backgroundColor('#2E7D32')
            .margin({ left: 8 })
            .onClick(() => this.read())
        }
        .width('100%')

        Text(`剪贴板有数据：${this.hasClip ? '是' : '未知/否'}`)
          .fontSize(12)
          .fontColor('#888')
          .width('100%')

        Text(`读到的内容：${this.clipText}`)
          .fontSize(13)
          .width('100%')
          .padding(10)
          .backgroundColor('#F5F7F9')
          .borderRadius(8)
          .copyOption(CopyOptions.InApp)

        Text(this.log)
          .fontSize(12)
          .fontColor('#317af7')
          .width('100%')
          .padding(8)
          .backgroundColor('#EEF4FF')
          .borderRadius(6)

        Text('零权限版本：上面这段结果文本加了 .copyOption(CopyOptions.InApp)，长按就能选中复制，不走系统剪贴板 API，也不弹任何提示。凡是「让用户复制这段文字」的需求，都应该先用这个，而不是自己调 pasteboard。')
          .fontSize(12)
          .fontColor('#555')
          .width('100%')

        Text('什么时候必须用 pasteboard：① 复制的内容是动态拼装、用户看不到全貌的（如邀请码、分享链接）；② 需要监听剪贴板变化做智能识别（订单号、地址）；③ 需要写入富文本/URI。')
          .fontSize(12)
          .fontColor('#555')
          .width('100%')

        Button('返回')
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => router.back())
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
  }
}
