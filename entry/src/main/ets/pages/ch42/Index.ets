import { router } from '@kit.ArkUI'

// Chapter 42: Scan Kit + camera (hardware interaction series, part 3)
//   Two ways to turn pixels into data:
//     - ScanKit: scanCore / scanBarcode / customScan / detectBarcode / generateBarcode
//       (from @kit.ScanKit on the HMS side)
//     - CameraKit: cameraPicker (zero-permission system camera) and the full
//       camera/cameraManager preview pipeline
@Entry
@Component
struct Ch42Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第42篇：扫码与相机')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('上一篇我们站在地面上找位置，这篇抬头看「镜头」：扫码把图案变成文本，拍照把光变成图片。两件事都绕不开 CameraKit，正好一起讲。')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        // ---------- ① Basic scan ----------
        Text('① 系统扫码（startScan 一行拿到结果）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('打开系统扫码')
          .width('92%')
          .onClick(() => router.pushUrl({ url: 'pages/ch42/Ch42ScanBasic' } as router.RouterOptions))

        // ---------- ② Scan types ----------
        Text('② 指定码制 + 相册识别（detectBarcode）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('打开码制与相册识码')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch42/Ch42ScanTypes' } as router.RouterOptions))

        // ---------- ③ Generate barcode ----------
        Text('③ 生成二维码（createBarcode 出图片）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('打开生成二维码')
          .width('92%')
          .backgroundColor('#6A1B9A')
          .onClick(() => router.pushUrl({ url: 'pages/ch42/Ch42BarcodeGen' } as router.RouterOptions))

        // ---------- ④ Camera picker ----------
        Text('④ 系统相机拍照（cameraPicker，零权限）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('打开系统相机拍照')
          .width('92%')
          .backgroundColor('#00838F')
          .onClick(() => router.pushUrl({ url: 'pages/ch42/Ch42CameraPicker' } as router.RouterOptions))

        Text('环境提示：ScanKit 属于 HMS 侧能力，模拟器没有摄像头也没有扫码服务，① ② 需要真机验证；③ 生成二维码、④ 系统相机拍照在模拟器也能跑（照片来自相册）。')
          .fontSize(12)
          .fontColor('#888')
          .width('92%')
          .margin({ top: 10 })

        Button('返回首页')
          .width('92%')
          .margin({ top: 16 })
          .onClick(() => router.back())
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }
}