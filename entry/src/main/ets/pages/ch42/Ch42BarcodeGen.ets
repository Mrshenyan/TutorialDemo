import { router } from '@kit.ArkUI'
import { image } from '@kit.ImageKit'
import { generateBarcode, scanCore } from '@kit.ScanKit'

interface BizErr { code: number; message: string }

// ③ Generate a barcode image with createBarcode().
//   It resolves with a PixelMap (not a file), so render it with Image(pixelMap).
@Entry
@Component
struct Ch42BarcodeGen {
  @State content: string = 'https://developer.huawei.com'
  @State qrPixelMap: image.PixelMap | undefined = undefined
  @State status: string = '点按钮生成二维码'
  @State busy: boolean = false
  @State pickedLevel: number = generateBarcode.ErrorCorrectionLevel.LEVEL_M

  // Error correction level: higher levels survive more damage but encode less data.
  private levelEnum: generateBarcode.ErrorCorrectionLevel[] = [
    generateBarcode.ErrorCorrectionLevel.LEVEL_L,
    generateBarcode.ErrorCorrectionLevel.LEVEL_M,
    generateBarcode.ErrorCorrectionLevel.LEVEL_Q,
    generateBarcode.ErrorCorrectionLevel.LEVEL_H
  ]

  private levelLabel(idx: number): string {
    if (idx === 0) { return 'LEVEL_L（约 7% 容错）' }
    if (idx === 1) { return 'LEVEL_M（约 15% 容错）' }
    if (idx === 2) { return 'LEVEL_Q（约 25% 容错）' }
    return 'LEVEL_H（约 30% 容错）'
  }

  private generate(): void {
    this.busy = true
    this.status = '生成中…'
    let opts: generateBarcode.CreateOptions = {
      scanType: scanCore.ScanType.QR_CODE,
      width: 600,
      height: 600,
      margin: 20,
      level: this.levelEnum[this.pickedLevel],
      backgroundColor: 0xFFFFFFFF,
      pixelMapColor: 0xFF000000
    }
    generateBarcode.createBarcode(this.content, opts)
      .then((pm: image.PixelMap) => {
        this.qrPixelMap = pm
        this.busy = false
        this.status = '生成成功'
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.busy = false
        this.status = `生成失败[${be.code}]：${be.message}`
      })
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('③ 生成二维码')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        Text('createBarcode(content, options) 返回 PixelMap，直接喂给 Image 组件渲染。扫码类应用里的「我的工牌/付款码」都是这么来的。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        Text('内容').fontSize(13).fontColor('#888').width('100%')
        TextInput({ placeholder: '输入要编码的文本', text: this.content })
          .width('100%')
          .onChange((v: string) => this.content = v)

        Text(`纠错等级：${this.levelLabel(this.pickedLevel)}`)
          .fontSize(13)
          .width('100%')

        Row() {
          ForEach(this.levelEnum, (l: generateBarcode.ErrorCorrectionLevel, i: number) => {
            Button(`${['L', 'M', 'Q', 'H'][i]}`)
              .layoutWeight(1)
              .fontSize(13)
              .margin({ right: i === 3 ? 0 : 6 })
              .backgroundColor(this.pickedLevel === l ? '#317af7' : '#999')
              .onClick(() => this.pickedLevel = l)
          }, (l: generateBarcode.ErrorCorrectionLevel, i: number) => `${i}`)
        }
        .width('100%')

        Button(this.busy ? '生成中…' : '生成二维码')
          .width('100%')
          .enabled(!this.busy)
          .backgroundColor('#6A1B9A')
          .onClick(() => this.generate())

        if (this.qrPixelMap !== undefined) {
          Image(this.qrPixelMap)
            .width(220)
            .height(220)
            .objectFit(ImageFit.Contain)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .margin({ top: 8 })

          Text(this.content)
            .fontSize(12)
            .fontFamily('monospace')
            .width('100%')
            .textAlign(TextAlign.Center)
        }

        Text(this.status)
          .fontSize(13)
          .fontColor(this.busy ? '#317af7' : '#2E7D32')
          .width('100%')

        Text(`踩坑提示：① 返回的是内存里的 PixelMap，不是文件，要落盘得自己用 imageKit 的 packer；② margin 是静区边距，太小会导致扫码识别率下降；③ 背景色/前景色是 0xAARRGGBB 格式的 number，不是 '#FFFFFF' 字符串。`)
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