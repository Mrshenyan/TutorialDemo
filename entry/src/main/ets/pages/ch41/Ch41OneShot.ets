import { router } from '@kit.ArkUI'
import { abilityAccessCtrl, common } from '@kit.AbilityKit'
import { geoLocationManager } from '@kit.LocationKit'

interface BizErr { code: number; message: string }

// ① One-shot fix: ask for the current location once and display every useful field.
//   getCurrentLocation(request) resolves with a Location carrying
//   latitude / longitude / altitude / accuracy / speed / direction / sourceType.
@Entry
@Component
struct Ch41OneShot {
  @State lat: number = 0
  @State lon: number = 0
  @State altitude: number = 0
  @State accuracy: number = 0
  @State speed: number = 0
  @State direction: number = 0
  @State source: string = '-'
  @State status: string = '点「开始定位」按钮获取当前位置'
  @State loading: boolean = false

  // Build the request as a typed variable first: ArkTS strict mode rejects
  // inline object literals for interface types in some positions.
  private startOnce(): void {
    this.loading = true
    this.status = '定位中…'
    let req: geoLocationManager.CurrentLocationRequest = {
      priority: geoLocationManager.LocationRequestPriority.ACCURACY,
      scenario: geoLocationManager.LocationRequestScenario.TRAJECTORY_TRACKING,
      maxAccuracy: 0,
      timeoutMs: 10000
    }
    geoLocationManager.getCurrentLocation(req)
      .then((loc: geoLocationManager.Location) => {
        this.lat = loc.latitude
        this.lon = loc.longitude
        this.altitude = loc.altitude
        this.accuracy = loc.accuracy
        this.speed = loc.speed
        this.direction = loc.direction
        this.source = this.sourceName(loc.sourceType)
        this.loading = false
        this.status = '定位成功'
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.loading = false
        this.status = `定位失败[${be.code}]：${be.message}`
      })
  }

  // sourceType tells whether the fix came from GNSS, network, indoor or RTK.
  private sourceName(t: number | undefined): string {
    if (t === geoLocationManager.LocationSourceType.GNSS) {
      return 'GNSS（卫星）'
    }
    if (t === geoLocationManager.LocationSourceType.NETWORK) {
      return 'NETWORK（网络基站）'
    }
    if (t === geoLocationManager.LocationSourceType.INDOOR) {
      return 'INDOOR（室内定位）'
    }
    if (t === geoLocationManager.LocationSourceType.RTK) {
      return 'RTK（实时差分）'
    }
    return '未知'
  }

  // APPROXIMATELY_LOCATION is a user_grant permission: declare it in module.json5
  // and still ask the user at runtime before the first fix.
  private requestPermissionThenLocate(): void {
    const atManager = abilityAccessCtrl.createAtManager()
    const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    atManager.requestPermissionsFromUser(ctx, ['ohos.permission.APPROXIMATELY_LOCATION'])
      .then(() => this.startOnce())
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.status = `权限申请被拒绝：${be.code} ${be.message}`
      })
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('① 一次性定位')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        Text('getCurrentLocation() 拿一次就返回。accuracy 越小越准，单位米。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        Button(this.loading ? '定位中…' : '开始定位')
          .width('100%')
          .enabled(!this.loading)
          .onClick(() => this.requestPermissionThenLocate())

        Row() {
          Column({ space: 4 }) {
            Text('纬度 latitude').fontSize(12).fontColor('#888')
            Text(this.lat.toFixed(6)).fontSize(16).fontFamily('monospace')
          }
          .layoutWeight(1)

          Column({ space: 4 }) {
            Text('经度 longitude').fontSize(12).fontColor('#888')
            Text(this.lon.toFixed(6)).fontSize(16).fontFamily('monospace')
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)

        Row() {
          Column({ space: 4 }) {
            Text('海拔 altitude(m)').fontSize(12).fontColor('#888')
            Text(this.altitude.toFixed(1)).fontSize(15).fontFamily('monospace')
          }
          .layoutWeight(1)

          Column({ space: 4 }) {
            Text('精度 accuracy(m)').fontSize(12).fontColor('#888')
            Text(this.accuracy.toFixed(1)).fontSize(15).fontFamily('monospace')
          }
          .layoutWeight(1)

          Column({ space: 4 }) {
            Text('速度 speed(m/s)').fontSize(12).fontColor('#888')
            Text(this.speed.toFixed(1)).fontSize(15).fontFamily('monospace')
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)

        Row() {
          Column({ space: 4 }) {
            Text('方向 direction(°)').fontSize(12).fontColor('#888')
            Text(this.direction.toFixed(1)).fontSize(15).fontFamily('monospace')
          }
          .layoutWeight(1)

          Column({ space: 4 }) {
            Text('来源 sourceType').fontSize(12).fontColor('#888')
            Text(this.source).fontSize(13)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)

        Text(this.status)
          .fontSize(13)
          .fontColor(this.loading ? '#317af7' : '#2E7D32')
          .width('100%')

        Text('提示：模拟器上可在「设置 → 位置信息」手动注入坐标；室内无卫星时 sourceType 常为 NETWORK。')
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