import { router } from '@kit.ArkUI'
import { image } from '@kit.ImageKit'
import { generateBarcode, scanCore } from '@kit.ScanKit'
import { systemShare } from '@kit.ShareKit'
import { uniformTypeDescriptor as utd } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { fileIo, fileUri } from '@kit.CoreFileKit'

interface BizErr { code: number; message: string }

// Chapter 44 - share a real file (image), not a string.
//
// Three steps that everybody trips over:
//   1. PixelMap in memory -> bytes (ImagePacker)
//   2. bytes -> a file inside the app sandbox (fileIo)
//   3. file path -> a URI the system share framework can grant to the receiver
//      (fileUri.getUriFromPath). Sharing a raw path string does not work.
class ShareImageKit {
  static async shareQrCode(ctx: common.UIAbilityContext, content: string): Promise<string> {
    let opts: generateBarcode.CreateOptions = {
      scanType: scanCore.ScanType.QR_CODE,
      width: 480,
      height: 480,
      margin: 16,
      backgroundColor: 0xFFFFFFFF,
      pixelMapColor: 0xFF000000
    }
    const pm: image.PixelMap = await generateBarcode.createBarcode(content, opts)

    const packer: image.ImagePacker = image.createImagePacker()
    let packOpt: image.PackingOption = { format: 'image/png', quality: 100 }
    const buf: ArrayBuffer = await packer.packing(pm, packOpt)
    await packer.release()

    const path: string = `${ctx.filesDir}/ch44_share_qr.png`
    const file: fileIo.File = fileIo.openSync(path,
      fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.TRUNC)
    fileIo.writeSync(file.fd, buf)
    fileIo.closeSync(file)

    const uri: string = fileUri.getUriFromPath(path)
    let record: systemShare.SharedRecord = {
      utd: utd.UniformDataType.IMAGE,
      uri: uri,
      title: '二维码图片',
      description: '沙箱文件经 URI 交给系统，接收方拿到的是临时读授权'
    }
    const controller: systemShare.ShareController =
      new systemShare.ShareController(new systemShare.SharedData(record))
    let shareOpts: systemShare.ShareControllerOptions = {
      previewMode: systemShare.SharePreviewMode.DEFAULT
    }
    await controller.show(ctx, shareOpts)
    return uri
  }
}

@Entry
@Component
struct Ch44ShareImage {
  @State content: string = 'https://github.com/Mrshenyan/TutorialDemo'
  @State status: string = '点按钮生成二维码并分享'
  @State busy: boolean = false

  private context(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext
  }

  private run(): void {
    this.busy = true
    this.status = '生成图片并拉起分享…'
    ShareImageKit.shareQrCode(this.context(), this.content)
      .then((uri: string) => {
        this.busy = false
        this.status = `已交给系统分享：${uri}`
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.busy = false
        this.status = `失败 [${be.code}] ${be.message}`
      })
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('② 分享图片（PixelMap → 文件 → URI）')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 12 })

        Text('文本能塞进 content，图片不行。图片必须先在沙箱里落成文件，再把 file:// URI 交给分享框架——系统会在用户选中目标应用时给它一个临时读授权。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        TextInput({ text: this.content })
          .width('100%')
          .onChange((v: string) => this.content = v)

        Button(this.busy ? '处理中…' : '生成二维码并分享')
          .width('100%')
          .enabled(!this.busy)
          .backgroundColor('#00838F')
          .onClick(() => this.run())

        Text(this.status)
          .fontSize(12)
          .fontColor('#317af7')
          .width('100%')
          .padding(8)
          .backgroundColor('#EEF4FF')
          .borderRadius(6)

        Text('三个必须记住的点').fontSize(14).fontWeight(FontWeight.Medium).width('100%')

        Text('① writeSync 的第二个参数必须是 ArrayBuffer，丢 Uint8Array 进去会写出乱码；② 沙箱路径不能直接分享，必须 fileUri.getUriFromPath() 转成 file:// URI；③ 文件落在 filesDir 里不需要任何存储权限，而把图片塞进相册才要 WRITE_IMAGEVIDEO。')
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
