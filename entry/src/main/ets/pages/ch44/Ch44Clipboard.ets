import { router } from '@kit.ArkUI'
import { pasteboard } from '@kit.BasicServicesKit'

interface BizErr { code: number; message: string }

// Chapter 44 - clipboard. Three ways to get text OUT of the clipboard, from
// lightest to heaviest:
//   1. Text().copyOption(CopyOptions.InApp): long-press to copy inside your
//      own app. Zero permission, zero prompt. Use this whenever the goal is
//      just "let the user copy this text".
//   2. PasteButton (security component): carries the read privilege itself,
//      so getData() inside its onClick succeeds with no prompt and no
//      permission. This is the supported zero-config way to READ.
//   3. ohos.permission.READ_PASTEBOARD: a restricted user_grant permission.
//      Declaring it is not enough - you also need an AGC profile with the
//      ACL granted, otherwise getData() silently returns nothing. Only worth
//      it for background/automatic reads (verification-code listeners etc.).
//
// Writing never needs any of this: setData() is treated as the user's own copy.
@Entry
@Component
struct Ch44Clipboard {
  @State input: string = '跟着cc一起学鸿蒙开发 · 第44篇'
  @State clipText: string = '（点上面的「粘贴」按钮读取）'
  @State log: string = '还没操作'
  @State hasClip: boolean = false
  @State changeCount: number = -1

  aboutToAppear(): void {
    this.refreshState()
  }

  private board(): pasteboard.SystemPasteboard {
    return pasteboard.getSystemPasteboard()
  }

  private write(): void {
    const data: pasteboard.PasteData =
      pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.input)
    this.board().setData(data)
      .then(() => {
        this.log = '已写入系统剪贴板（切到别的 App 长按输入框就能粘贴）'
        this.refreshState()
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.log = `写入失败 [${be.code}] ${be.message}`
      })
  }

  // PasteButton click. The system grants a *temporary* read authorization to
  // this process - no dialog, no permission - and it is revoked when the
  // screen turns off, the app goes to background, or the app exits.
  private onPaste(event: ClickEvent, result: PasteButtonOnClickResult): void {
    if (result !== PasteButtonOnClickResult.SUCCESS) {
      // The button must stay visible and legible; hiding or restyling it into
      // illegibility is treated as an authorization failure.
      this.log = '粘贴授权失败：按钮被遮挡或样式导致不可读'
      return
    }
    this.readClipboard('PasteButton')
  }

  private readClipboard(tag: string): void {
    if (!this.hasClip) {
      this.log = `[${tag}] 剪贴板是空的——先点「写入剪贴板」再读`
      return
    }
    this.board().getData()
      .then((d: pasteboard.PasteData) => {
        try {
          const text: string = d.getPrimaryText()
          this.clipText = text.length > 0 ? text : '（剪贴板里没有纯文本，可能是图片或 URI）'
          this.log = `[${tag}] 读取成功 · mime=${d.getPrimaryMimeType()}`
        } catch (e) {
          this.log = `[${tag}] 数据在但不是文本：${JSON.stringify(e)}`
        }
        this.refreshState()
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        // 12900003 = another copy/paste operation is in progress.
        if (be.code === 12900003) {
          this.log = `[${tag}] 另一个粘贴操作正在进行，稍候再试`
          return
        }
        this.log = `[${tag}] 读取失败 [${be.code}] ${be.message}`
      })
  }

  // hasData()/getChangeCount() are the documented pre-checks: they cost
  // nothing and keep you from reading data you cannot use.
  private refreshState(): void {
    this.board().hasData()
      .then((ok: boolean) => {
        this.hasClip = ok
      })
      .catch(() => {
        this.hasClip = false
      })
    this.changeCount = this.board().getChangeCount()
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('③ 剪贴板：写入、读取、以及「别乱读」')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 12 })

        Text('写入随时可以（视为用户自己的复制）；读取有三条路，从轻到重：应用内 copyOption → 粘贴控件 → 受限权限。')
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

          // Security component: icon + text + capsule background are all
          // mandatory and non-customizable. It must stay visible, or the
          // temporary authorization fails.
          PasteButton()
            .layoutWeight(1)
            .margin({ left: 8 })
            .onClick((event: ClickEvent, result: PasteButtonOnClickResult) => {
              this.onPaste(event, result)
            })
        }
        .width('100%')

        Row() {
          Text(`剪贴板有数据：${this.hasClip ? '是' : '否'}`)
            .fontSize(12)
            .fontColor('#888')
          Blank()
          Text(`changeCount=${this.changeCount}`)
            .fontSize(12)
            .fontColor('#888')
        }
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

        Text('三条路线怎么选：')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ top: 6 })

        Text('① copyOption(CopyOptions.InApp)：让用户长按复制你页面上的文字。零权限零弹窗，90% 的需求用这个就够。')
          .fontSize(12)
          .fontColor('#555')
          .width('100%')

        Text('② PasteButton 粘贴控件：需要把剪贴板内容读进 App（验证码、链接、订单号）。按钮自带读取特权，点击后直接读，不弹窗、不申请权限。')
          .fontSize(12)
          .fontColor('#555')
          .width('100%')

        Text('③ READ_PASTEBOARD 受限权限：后台自动监听剪贴板才走这条。要 AGC 申请 Profile，个人开发者流程长，且每次读取仍要用户授权。')
          .fontSize(12)
          .fontColor('#555')
          .width('100%')

        Text('注意临时授权的生命周期：灭屏、App 退后台、App 退出，任意一个发生，授权自动撤销。下次读取要重新点 PasteButton。授权期内调用次数不限。')
          .fontSize(12)
          .fontColor('#B26A00')
          .width('100%')
          .padding(10)
          .backgroundColor('#FFF8E5')
          .borderRadius(8)

        Text('官方最佳实践：读取前先用 hasData() 判空、用 getChangeCount() 和上次记录比较判断内容是否变过、用 detectPatterns() 判断是不是你要的数据类型——都不需要权限，能避免大量无效授权请求。')
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
