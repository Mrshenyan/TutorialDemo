import { router } from '@kit.ArkUI'
import { camera, cameraPicker } from '@kit.CameraKit'

interface BizErr { code: number; message: string }

// ④ Take a photo with the system camera picker.
//
//   cameraPicker.pick() needs NO camera permission: the picker runs in its own
//   system Ability, so the app only receives a temporary uri. It returns
//   PickerResult{ resultCode, resultUri, mediaType }.
//   Pick PHOTO vs VIDEO and back/front, then show the resulting uri on screen.
@Entry
@Component
struct Ch42CameraPicker {
  @State photoUri: string = ''
  @State mediaTypeName: string = ''
  @State resultCodeName: string = ''
  @State status: string = '点按钮打开系统相机'
  @State busy: boolean = false
  @State useVideo: boolean = false
  @State frontCamera: boolean = false

  private openPicker(): void {
    this.busy = true
    this.status = '等待相机返回…'
    let position: camera.CameraPosition = this.frontCamera ?
      camera.CameraPosition.CAMERA_POSITION_FRONT : camera.CameraPosition.CAMERA_POSITION_BACK
    let profile: cameraPicker.PickerProfile = {
      cameraPosition: position
    }
    let mediaTypes: cameraPicker.PickerMediaType[] = [this.useVideo ?
      cameraPicker.PickerMediaType.VIDEO : cameraPicker.PickerMediaType.PHOTO]

    cameraPicker.pick(getContext(this), mediaTypes, profile)
      .then((res: cameraPicker.PickerResult) => {
        this.busy = false
        this.photoUri = res.resultUri
        this.mediaTypeName = res.mediaType
        this.resultCodeName = this.resultCodeText(res.resultCode)
        this.status = '拍照/录像完成'
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.busy = false
        this.status = `相机未返回[${be.code}]：${be.message}（用户取消也走这里）`
      })
  }

  // resultCode is a number; translate it into a readable phrase.
  private resultCodeText(code: number): string {
    if (code === 0) { return '0（成功）' }
    if (code === 1) { return '1（用户取消）' }
    if (code === 2) { return '2（其他异常）' }
    return `${code}（未知）`
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('④ 系统相机拍照')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        Text('cameraPicker.pick() 拉起的是系统相机页面，你不用申请 ohos.permission.CAMERA，也不用自己管理 Surface。适合「头像上传 / 拍个凭证」这类快闪需求。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        // ---- option toggles ----
        Row() {
          Button(this.useVideo ? '当前：录像' : '当前：拍照')
            .layoutWeight(1)
            .backgroundColor(this.useVideo ? '#00838F' : '#317af7')
            .onClick(() => this.useVideo = !this.useVideo)

          Button(this.frontCamera ? '当前：前置' : '当前：后置')
            .layoutWeight(1)
            .margin({ left: 10 })
            .backgroundColor(this.frontCamera ? '#6A1B9A' : '#2E7D32')
            .onClick(() => this.frontCamera = !this.frontCamera)
        }
        .width('100%')

        Button(this.busy ? '打开相机中…' : '打开相机')
          .width('100%')
          .enabled(!this.busy)
          .backgroundColor('#00838F')
          .onClick(() => this.openPicker())

        if (this.photoUri.length > 0) {
          Column({ space: 6 }) {
            Text('返回结果').fontSize(14).fontWeight(FontWeight.Medium).width('100%')
            this.infoRow('resultCode', this.resultCodeName)
            Divider()
            this.infoRow('mediaType', this.mediaTypeName)
            Divider()
            Text('resultUri')
              .fontSize(12)
              .fontColor('#888')
              .width('100%')
            Text(this.photoUri)
              .fontSize(11)
              .fontFamily('monospace')
              .width('100%')
              .copyOption(CopyOptions.InApp)
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .alignItems(HorizontalAlign.Start)

          // resultUri is a file:// uri, so Image can load it directly.
          Image(this.photoUri)
            .width('100%')
            .height(360)
            .objectFit(ImageFit.Contain)
            .backgroundColor('#111111')
            .borderRadius(8)
        }

        Text(this.status)
          .fontSize(13)
          .fontColor(this.busy ? '#317af7' : '#2E7D32')
          .width('100%')

        Text('踩坑提示：① resultUri 是系统给的临时文件 uri，应用重启后可能失效；想长期保存，请把内容复制到沙箱或通过 photoAccessHelper 写入相册。② 用户取消拍照走 reject 分支而不是 resultCode=1 正常返回，两条路都要处理。')
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
      Text(label).fontSize(13).fontColor('#888').width(100)
      Text(value).fontSize(13).layoutWeight(1)
    }
    .width('100%')
  }
}