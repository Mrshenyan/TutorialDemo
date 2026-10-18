import { router } from '@kit.ArkUI'
import { abilityAccessCtrl, common } from '@kit.AbilityKit'
import { geoLocationManager } from '@kit.LocationKit'

interface BizErr { code: number; message: string }

// ② Continuous tracking: subscribe with on('locationChange') and plot a trail.
//   Two extra channels matter here: locationError (fix failed) and
//   locationEnabledChange (user turned location off in system settings).
@Entry
@Component
struct Ch41Continuous {
  @State lat: number = 0
  @State lon: number = 0
  @State accuracy: number = 0
  @State speed: number = 0
  @State count: number = 0
  @State tracking: boolean = false
  @State status: string = '未开始'
  @State switchOn: boolean = true
  // Screen-ready points: [x0, y0, x1, y1, ...] inside a 260x200 box.
  @State trail: number[] = []

  // Raw fixes stay in a plain field: they grow fast and must not drive re-render.
  private pathRaw: number[] = []

  // Keep stable callback references so off() unsubscribes exactly the same ones.
  private locCb: (loc: geoLocationManager.Location) => void = (loc: geoLocationManager.Location) => {
    this.lat = loc.latitude
    this.lon = loc.longitude
    this.accuracy = loc.accuracy
    this.speed = loc.speed
    this.count = this.count + 1
    this.status = `定位中…已收到 ${this.count} 次`
    this.pathRaw.push(loc.latitude, loc.longitude)
    // Bound the buffer so a long session cannot grow without limit.
    if (this.pathRaw.length > 600) {
      this.pathRaw = this.pathRaw.slice(this.pathRaw.length - 600)
    }
    this.trail = this.buildTrail()
  }

  private errCb: (err: geoLocationManager.LocationError) => void =
    (err: geoLocationManager.LocationError) => {
      this.status = `定位出错：${this.errorName(err)}`
    }

  private switchCb: (enabled: boolean) => void = (enabled: boolean) => {
    this.switchOn = enabled
    if (!enabled) {
      this.status = '系统定位开关已被关闭'
    }
  }

  // LocationError is a numeric enum: translate it into a readable phrase.
  private errorName(e: geoLocationManager.LocationError): string {
    if (e === geoLocationManager.LocationError.LOCATING_FAILED_DEFAULT) {
      return '定位失败（默认错误，可能是无信号）'
    }
    if (e === geoLocationManager.LocationError.LOCATING_FAILED_LOCATION_PERMISSION_DENIED) {
      return '定位权限被拒绝'
    }
    if (e === geoLocationManager.LocationError.LOCATING_FAILED_BACKGROUND_PERMISSION_DENIED) {
      return '后台定位权限被拒绝'
    }
    if (e === geoLocationManager.LocationError.LOCATING_FAILED_LOCATION_SWITCH_OFF) {
      return '系统定位开关未开启'
    }
    if (e === geoLocationManager.LocationError.LOCATING_FAILED_INTERNET_ACCESS_FAILURE) {
      return '网络不可用（网络定位失败）'
    }
    return `未知错误 ${e}`
  }

  private startTrack(): void {
    try {
      // ContinuousLocationRequest: interval is the callback period in milliseconds,
      // locationScenario trades precision against power.
      let req: geoLocationManager.ContinuousLocationRequest = {
        interval: 1000,
        locationScenario: geoLocationManager.UserActivityScenario.DAILY_LIFE_SERVICE,
        needPoi: false
      }
      geoLocationManager.on('locationChange', req, this.locCb)
      geoLocationManager.on('locationError', this.errCb)
      geoLocationManager.on('locationEnabledChange', this.switchCb)
      this.tracking = true
      this.status = '已订阅，等待首次定位…'
    } catch (e) {
      const be: BizErr = e as BizErr
      this.status = `订阅失败[${be.code}]：${be.message}`
    }
  }

  private stopTrack(): void {
    geoLocationManager.off('locationChange', this.locCb)
    geoLocationManager.off('locationError', this.errCb)
    geoLocationManager.off('locationEnabledChange', this.switchCb)
    this.tracking = false
    this.status = '已取消订阅'
  }

  private clearTrail(): void {
    this.pathRaw = []
    this.trail = []
    this.count = 0
  }

  private requestPermissionThenTrack(): void {
    const atManager = abilityAccessCtrl.createAtManager()
    const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    atManager.requestPermissionsFromUser(ctx, ['ohos.permission.APPROXIMATELY_LOCATION'])
      .then(() => this.startTrack())
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.status = `权限申请被拒绝：${be.code} ${be.message}`
      })
  }

  // Normalize the raw fixes around the bounding box so nearby points fill the
  // drawing area instead of collapsing into a single pixel.
  private buildTrail(): number[] {
    if (this.pathRaw.length < 4) {
      return []
    }
    let minLat: number = this.pathRaw[0]
    let maxLat: number = this.pathRaw[0]
    let minLon: number = this.pathRaw[1]
    let maxLon: number = this.pathRaw[1]
    for (let i = 0; i < this.pathRaw.length; i += 2) {
      if (this.pathRaw[i] < minLat) { minLat = this.pathRaw[i] }
      if (this.pathRaw[i] > maxLat) { maxLat = this.pathRaw[i] }
      if (this.pathRaw[i + 1] < minLon) { minLon = this.pathRaw[i + 1] }
      if (this.pathRaw[i + 1] > maxLon) { maxLon = this.pathRaw[i + 1] }
    }
    // Math.max(..., 0.000001) guards against dividing by zero when standing still.
    const spanLat: number = Math.max(maxLat - minLat, 0.000001)
    const spanLon: number = Math.max(maxLon - minLon, 0.000001)
    let out: number[] = []
    for (let i = 0; i < this.pathRaw.length; i += 2) {
      const x: number = ((this.pathRaw[i + 1] - minLon) / spanLon) * 240
      // Latitude grows northwards while screen y grows downwards: invert it.
      const y: number = 180 - ((this.pathRaw[i] - minLat) / spanLat) * 180
      out.push(x, y)
    }
    return out
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('② 连续定位')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        Text('on(\'locationChange\', req, cb) 持续回调。走两步试试，轨迹点会画在下面方框里。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        Button(this.tracking ? '停止追踪' : '开始追踪')
          .width('100%')
          .backgroundColor(this.tracking ? '#d32f2f' : '#2E7D32')
          .onClick(() => {
            if (this.tracking) {
              this.stopTrack()
            } else {
              this.requestPermissionThenTrack()
            }
          })

        Button('清空轨迹')
          .width('100%')
          .backgroundColor('#999')
          .onClick(() => this.clearTrail())

        Row() {
          Column({ space: 4 }) {
            Text('回调次数').fontSize(12).fontColor('#888')
            Text(`${this.count}`).fontSize(18).fontFamily('monospace')
          }
          .layoutWeight(1)

          Column({ space: 4 }) {
            Text('精度(m)').fontSize(12).fontColor('#888')
            Text(this.accuracy.toFixed(1)).fontSize(18).fontFamily('monospace')
          }
          .layoutWeight(1)

          Column({ space: 4 }) {
            Text('速度(m/s)').fontSize(12).fontColor('#888')
            Text(this.speed.toFixed(1)).fontSize(18).fontFamily('monospace')
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)

        Text(`lat ${this.lat.toFixed(6)}  lon ${this.lon.toFixed(6)}`)
          .fontSize(12)
          .fontFamily('monospace')
          .width('100%')

        Text(`系统定位开关：${this.switchOn ? '开' : '关'}`)
          .fontSize(12)
          .fontColor(this.switchOn ? '#2E7D32' : '#d32f2f')
          .width('100%')

        // Trail canvas: one small circle per recorded fix.
        Stack() {
          if (this.trail.length === 0) {
            Text('移动手机后出现轨迹点')
              .fontSize(12)
              .fontColor('#aaa')
          } else {
            // Key by index: repeated coordinates would collide on a value-based key.
            ForEach(this.trail, (v: number, i: number) => {
              if (i % 2 === 0) {
                Circle({ width: 6, height: 6 })
                  .fill('#2E7D32')
                  .position({ x: v + 10, y: this.trail[i + 1] + 10 })
              }
            }, (v: number, i: number) => `${i}`)
          }
        }
        .width(260)
        .height(200)
        .backgroundColor('#F2F2F2')
        .borderRadius(8)

        Text(this.status)
          .fontSize(13)
          .fontColor(this.tracking ? '#2E7D32' : '#666')
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