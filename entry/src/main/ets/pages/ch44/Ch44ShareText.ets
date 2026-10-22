import { router } from '@kit.ArkUI'
import { systemShare } from '@kit.ShareKit'
import { uniformTypeDescriptor as utd } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

interface BizErr { code: number; message: string }

// Chapter 44 - system share sheet, text / hyperlink flavour.
// ShareKit is an HMS-side kit: the panel is drawn by the system, our app only
// hands over a SharedData and never learns who the user picked (unless we
// register shareCompleted).
@Entry
@Component
struct Ch44ShareText {
  @State text: string = '跟着cc一起学鸿蒙开发 · 第44篇：系统分享与剪贴板'
  @State link: string = 'https://github.com/Mrshenyan/TutorialDemo'
  @State log: string = '还没开始分享'

  private context(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext
  }

  // Both flavours share this tail: wrap the record, show the panel, listen for
  // the completion callback (API 18+).
  private present(record: systemShare.SharedRecord, tag: string): void {
    const data: systemShare.SharedData = new systemShare.SharedData(record)
    const controller: systemShare.ShareController = new systemShare.ShareController(data)

    controller.on('shareCompleted', (result: systemShare.ShareOperationResult) => {
      this.log = `[${tag}] 分享完成 → ${JSON.stringify(result)}`
    })

    let opts: systemShare.ShareControllerOptions = {
      previewMode: systemShare.SharePreviewMode.DETAIL
    }
    controller.show(this.context(), opts)
      .then(() => {
        this.log = `[${tag}] 分享面板已拉起`
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.log = `[${tag}] 分享失败 [${be.code}] ${be.message}`
      })
  }

  private shareText(): void {
    let record: systemShare.SharedRecord = {
      utd: utd.UniformDataType.PLAIN_TEXT,
      content: this.text,
      title: '一段纯文本',
      description: '接收方拿到的是可直接落进输入框的字符串'
    }
    this.present(record, 'text')
  }

  private shareLink(): void {
    let record: systemShare.SharedRecord = {
      utd: utd.UniformDataType.HYPERLINK,
      content: this.link,
      title: '教程仓库',
      description: '带链接预览的卡片'
    }
    this.present(record, 'link')
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('① 分享文本 / 链接')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 12 })

        Text('ShareController(data).show(context, options) 拉起系统分享面板。utd 决定接收方怎么理解这份数据：PLAIN_TEXT 是纯文本，HYPERLINK 会被识别成可点击的链接。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        Text('要分享的文本').fontSize(13).fontColor('#888').width('100%')
        TextArea({ text: this.text })
          .width('100%')
          .height(80)
          .onChange((v: string) => this.text = v)

        Text('要分享的链接').fontSize(13).fontColor('#888').width('100%')
        TextInput({ text: this.link })
          .width('100%')
          .onChange((v: string) => this.link = v)

        Row() {
          Button('分享文本')
            .layoutWeight(1)
            .onClick(() => this.shareText())
          Button('分享链接')
            .layoutWeight(1)
            .backgroundColor('#2E7D32')
            .margin({ left: 8 })
            .onClick(() => this.shareLink())
        }
        .width('100%')

        Text(this.log)
          .fontSize(12)
          .fontColor('#317af7')
          .width('100%')
          .padding(8)
          .backgroundColor('#EEF4FF')
          .borderRadius(6)

        Text('踩坑：utd 填错比不填还糟。文本用 PLAIN_TEXT、网址用 HYPERLINK、图片用 IMAGE，填成 IMAGE 却只给 content 不给 uri，面板会拉起来但接收方打不开。批量/多选模式（SelectionMode.BATCH）只支持 UDMF.File 类型记录，传文本会直接抛 1003702001。')
          .fontSize(12)
          .fontColor('#888')
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
