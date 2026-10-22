import { router } from '@kit.ArkUI'
import { scanBarcode, scanCore } from '@kit.ScanKit'

interface BizErr { code: number; message: string }

// ① Basic scan: let the system scanner do everything.
//   startScan() resolves with ScanResult{ scanType, originalValue, scanCodeRect, ... }.
//   Cancel is NOT signalled by rejecting: ScanErrorCode.SCAN_SERVICE_CANCELED is a normal path.
@Entry
@Component
struct Ch42ScanBasic {
  @State value: string = ''
  @State typeName: string = ''
  @State rectInfo: string = ''
  @State status: string = '点「开始扫码」拉起系统扫码界面'
  @State scanning: boolean = false

  private handleResult(r: scanBarcode.ScanResult): void {
    this.value = r.originalValue
    this.typeName = this.scanTypeName(r.scanType)
    if (r.scanCodeRect) {
      this.rectInfo = `left=${r.scanCodeRect.left} top=${r.scanCodeRect.top} ` +
        `right=${r.scanCodeRect.right} bottom=${r.scanCodeRect.bottom}`
    } else {
      this.rectInfo = '无位置信息'
    }
    this.scanning = false
    this.status = '扫码成功'
  }

  private startScan(): void {
    this.scanning = true
    this.status = '扫码中…'
    let opts: scanBarcode.ScanOptions = {
      // Limit to 1D + QR to keep the scanner fast; drop this field to accept ALL.
      scanTypes: [scanCore.ScanType.QR_CODE, scanCore.ScanType.EAN13_CODE],
      enableMultiMode: false,
      enableAlbum: false
    }
    // startScan(options?) has a context-free overload: the system scanner runs
    // in its own Ability, so we only pass the options.
    scanBarcode.startScan(opts)
      .then((r: scanBarcode.ScanResult) => this.handleResult(r))
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.scanning = false
        // The user closing the scanner is expected: report it as a normal cancel.
        if (be.code === scanCore.ScanErrorCode.SCAN_SERVICE_CANCELED) {
          this.status = '已取消扫码'
        } else {
          this.status = `扫码失败[${be.code}]：${be.message}`
        }
      })
  }

  private scanTypeName(t: scanCore.ScanType): string {
    if (t === scanCore.ScanType.QR_CODE) { return 'QR_CODE（二维码）' }
    if (t === scanCore.ScanType.EAN13_CODE) { return 'EAN13（商品条码）' }
    if (t === scanCore.ScanType.CODE128_CODE) { return 'CODE128' }
    if (t === scanCore.ScanType.PDF417_CODE) { return 'PDF417' }
    if (t === scanCore.ScanType.AZTEC_CODE) { return 'AZTEC' }
    if (t === scanCore.ScanType.DATAMATRIX_CODE) { return 'DATAMATRIX' }
    if (t === scanCore.ScanType.ONE_D_CODE) { return 'ONE_D（一维码合集）' }
    if (t === scanCore.ScanType.TWO_D_CODE) { return 'TWO_D（二维码合集）' }
    return `其他码制(${t})`
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('① 系统扫码')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        Text('一行 startScan() 就完事：系统自己开摄像头、识别、返回结果。适合「登录扫个码」这种简单场景。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        Button(this.scanning ? '扫码中…' : '开始扫码')
          .width('100%')
          .enabled(!this.scanning)
          .onClick(() => this.startScan())

        if (this.value.length > 0) {
          Column({ space: 8 }) {
            Text('原始内容 originalValue').fontSize(12).fontColor('#888').width('100%')
            Text(this.value)
              .fontSize(15)
              .fontFamily('monospace')
              .width('100%')
              .copyOption(CopyOptions.InApp)
            Divider()
            this.infoRow('码制', this.typeName)
            Divider()
            this.infoRow('位置', this.rectInfo)
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .alignItems(HorizontalAlign.Start)

          // Text.copyOption(CopyOptions.InApp) makes the value selectable and
          // copyable without touching the pasteboard API.
          Button('长按上方文本可复制')
            .width('100%')
            .backgroundColor('#999')
            .enabled(false)
        }

        Text(this.status)
          .fontSize(13)
          .fontColor(this.scanning ? '#317af7' : '#2E7D32')
          .width('100%')

        Text('踩坑提示：用户中途退出不会抛异常「取消」，而是 reject 一个 SCAN_SERVICE_CANCELED(1000500002)，要单独判它，否则会误报成错误弹窗。')
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

  @Builder
  private infoRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(13).fontColor('#888').width(70)
      Text(value).fontSize(13).layoutWeight(1)
    }
    .width('100%')
  }
}