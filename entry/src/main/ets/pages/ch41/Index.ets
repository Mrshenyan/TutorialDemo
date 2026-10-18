import { router } from '@kit.ArkUI'

// Chapter 41: Location Kit (hardware interaction series, part 2)
//   After sensors (ch40), the next hardware capability is position.
//   One-shot fix via getCurrentLocation(), continuous tracking via on('locationChange'),
//   reverse geocoding turns coordinates into a readable Chinese address,
//   and geofencing lets the app react when you enter/leave an area.
@Entry
@Component
struct Ch41Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第41篇：定位 Location Kit')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('上一篇我们订阅了加速度、光线这些「身体里的传感器」，这篇走向手机外部：拿到你在地球上的坐标。一次性定位、连续追踪、逆地理编码、地理围栏，四件事一次讲透。')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        // ---------- ① One-shot fix ----------
        Text('① 一次性定位（拿当前经纬度 + 精度 + 高度）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('打开一次性定位')
          .width('92%')
          .onClick(() => router.pushUrl({ url: 'pages/ch41/Ch41OneShot' } as router.RouterOptions))

        // ---------- ② Continuous tracking ----------
        Text('② 连续定位（订阅变化，画一条轨迹）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('打开连续定位')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch41/Ch41Continuous' } as router.RouterOptions))

        // ---------- ③ Reverse geocoding ----------
        Text('③ 逆地理编码（经纬度 → 中文地址）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('打开逆地理编码')
          .width('92%')
          .backgroundColor('#6A1B9A')
          .onClick(() => router.pushUrl({ url: 'pages/ch41/Ch41ReverseGeo' } as router.RouterOptions))

        // ---------- ④ Geofence ----------
        Text('④ 地理围栏（进出区域自动提醒）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('打开地理围栏')
          .width('92%')
          .backgroundColor('#00838F')
          .onClick(() => router.pushUrl({ url: 'pages/ch41/Ch41Geofence' } as router.RouterOptions))

        Text('权限说明：定位使用 ohos.permission.APPROXIMATELY_LOCATION（user_grant），真机必须运行时动态申请；本工程 module.json5 已声明 reason + usedScene。模拟器可在「设置 → 位置信息」注入模拟坐标，无 GPS 也能跑通。')
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