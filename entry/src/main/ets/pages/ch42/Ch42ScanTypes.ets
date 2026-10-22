import { router } from '@kit.ArkUI'
import { camera, cameraPicker } from '@kit.CameraKit'
import { detectBarcode, scanBarcode } from '@kit.ScanKit'

interface BizErr { code: number; message: string }

// ② Scan types + album decoding.
//   Part A: the ScanType enum (QR / EAN13 / CODE128 ... plus ONE_D / TWO_D bundles)
//   Part B: pick a photo with the zero-permission system picker, then decode the
//           image file with detectBarcode.decode({ uri }) -- no camera scan needed.
@Entry
@Component
struct Ch42ScanTypes {
  @State pickedUri: string = ''
  @State results: string[] = []
  @State status: string = '选一张含二维码/条形码的图片进行识别'
  @State busy: boolean = false

  // The full ScanType set as strings, shown for reference.
  private allTypes: string[] = [
    'FORMAT_UNKNOWN=0', 'AZTEC_CODE=1', 'CODABAR_CODE=2', 'CODE39_CODE=3',
    'CODE93_CODE=4', 'CODE128_CODE=5', 'DATAMATRIX_CODE=6', 'EAN8_CODE=7',
    'EAN13_CODE=8', 'ITF14_CODE=9', 'PDF417_CODE=10', 'QR_CODE=11',
    'UPC_A_CODE=12', 'UPC_E_CODE=13', 'MULTIFUNCTIONAL_CODE=14',
    'ONE_D_CODE=100', 'TWO_D_CODE=101', 'ALL=1001'
  ]

  // Zero-permission path: the system picker returns a temporary uri.
  private pickImage(): void {
    let profile: cameraPicker.PickerProfile = {
      cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
    }
    cameraPicker.pick(getContext(this), [cameraPicker.PickerMediaType.PHOTO], profile)
      .then((res: cameraPicker.PickerResult) => {
        this.pickedUri = res.resultUri
        this.decodeUri(res.resultUri)
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.status = `选择图片失败[${be.code}]：${be.message}`
      })
  }

  // decode() takes an InputImage{ uri }, i.e. a picture on disk.
  private decodeUri(uri: string): void {
    this.busy = true
    this.status = '识别中…'
    let input: detectBarcode.InputImage = { uri: uri }
    detectBarcode.decode(input)
      .then((list: Array<scanBarcode.ScanResult>) => {
        this.busy = false
        if (list.length === 0) {
          this.results = []
          this.status = '这张图片里没有识别到码'
          return
        }
        let lines: string[] = []
        for (let i = 0; i < list.length; i++) {
          lines.push(`[${list[i].scanType}] ${list[i].originalValue}`)
        }
        this.results = lines
        this.status = `识别到 ${list.length} 个码`
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.busy = false
        this.status = `识别失败[${be.code}]：${be.message}`
      })
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('② 码制与相册识码')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        Text('扫码不只是二维码。scanCore.ScanType 定义了 18 种码制，ONE_D / TWO_D / ALL 可以一次覆盖一整类。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        // ---- ScanType list ----
        Column({ space: 4 }) {
          Text('ScanType 全量码制')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .width('100%')
          ForEach(this.allTypes, (t: string, i: number) => {
            Text(t).fontSize(11).fontFamily('monospace').width('100%')
          }, (t: string, i: number) => `${i}`)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        // ---- album decode ----
        Text('相册识码：选图 → decode({ uri })')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ top: 8 })

        Text('cameraPicker 拉起系统相册选择器，零权限；拿到 uri 后交给 detectBarcode 离线识别。适合「识别相册里已有的发票/快递码」。')
          .fontSize(12)
          .fontColor('#888')
          .width('100%')

        Button(this.busy ? '识别中…' : '选择图片并识别')
          .width('100%')
          .enabled(!this.busy)
          .backgroundColor('#2E7D32')
          .onClick(() => this.pickImage())

        if (this.pickedUri.length > 0) {
          Text(`已选：${this.pickedUri.substring(0, 40)}...`)
            .fontSize(11)
            .fontFamily('monospace')
            .fontColor('#888')
            .width('100%')
        }

        if (this.results.length > 0) {
          Column({ space: 6 }) {
            Text('识别结果').fontSize(14).fontWeight(FontWeight.Medium).width('100%')
            ForEach(this.results, (r: string, i: number) => {
              Text(r).fontSize(12).fontFamily('monospace').width('100%')
            }, (r: string, i: number) => `${i}`)
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#E8F5E9')
          .borderRadius(8)
          .alignItems(HorizontalAlign.Start)
        }

        Text(this.status)
          .fontSize(13)
          .fontColor(this.busy ? '#317af7' : '#2E7D32')
          .width('100%')

        Text('踩坑提示：detectBarcode.decode 的入参是 InputImage{ uri }，必须是「图片文件」而不是 PixelMap；想在相册里挑图，得先通过 photoAccessHelper 拿到 photoUri，不能直接拿内存图片去 decode。')
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