import { router } from '@kit.ArkUI'
import { abilityAccessCtrl, common } from '@kit.AbilityKit'
import { geoLocationManager } from '@kit.LocationKit'

interface BizErr { code: number; message: string }

// ④ Geofence: react when the user enters or leaves an area.
//   The real system API is on('gnssFenceStatusChange', GeofenceRequest, WantAgent):
//   it needs a WantAgent (the system launches an Ability for you) plus a
//   FenceExtensionAbility, so it cannot be fully exercised on the simulator.
//   Here we do two things:
//     1) show the real API shape and what each field means;
//     2) run a self-contained distance check so the logic works anywhere.
@Entry
@Component
struct Ch41Geofence {
  // Fence center: Tiananmen by default, so the demo is meaningful out of the box.
  @State fenceLat: number = 39.9087
  @State fenceLon: number = 116.3975
  @State fenceRadius: number = 500 // meters

  @State curLat: number = 0
  @State curLon: number = 0
  @State distance: number = 0
  @State inside: boolean = false
  @State log: string = '点击「获取当前位置」开始测试'
  @State loading: boolean = false

  private logs: string[] = []

  // Haversine formula: great-circle distance in meters between two WGS84 points.
  private haversine(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R: number = 6371000 // earth radius in meters
    const toRad: number = Math.PI / 180
    const dLat: number = (lat2 - lat1) * toRad
    const dLon: number = (lon2 - lon1) * toRad
    const a: number = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(lat1 * toRad) * Math.cos(lat2 * toRad) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2)
    const c: number = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    return R * c
  }

  private pushLog(msg: string): void {
    this.logs.unshift(msg)
    if (this.logs.length > 6) {
      this.logs = this.logs.slice(0, 6)
    }
    this.log = msg
  }

  private checkPosition(): void {
    this.loading = true
    let req: geoLocationManager.CurrentLocationRequest = {
      priority: geoLocationManager.LocationRequestPriority.ACCURACY,
      timeoutMs: 10000
    }
    geoLocationManager.getCurrentLocation(req)
      .then((loc: geoLocationManager.Location) => {
        this.loading = false
        this.curLat = loc.latitude
        this.curLon = loc.longitude
        this.distance = this.haversine(this.fenceLat, this.fenceLon, loc.latitude, loc.longitude)
        // Radius must exceed the reported accuracy, otherwise noise flips the state.
        const nowInside: boolean = this.distance <= this.fenceRadius
        if (nowInside !== this.inside) {
          this.inside = nowInside
          this.pushLog(nowInside
            ? `已进入围栏（距离 ${this.distance.toFixed(0)}m ≤ ${this.fenceRadius}m）`
            : `已离开围栏（距离 ${this.distance.toFixed(0)}m > ${this.fenceRadius}m）`)
        } else {
          this.pushLog(`仍在${nowInside ? '围栏内' : '围栏外'}，距离 ${this.distance.toFixed(0)}m`)
        }
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.loading = false
        this.pushLog(`定位失败[${be.code}]：${be.message}`)
      })
  }

  // Simulate a position so the enter/leave logic can be verified without moving.
  private simulate(inside: boolean): void {
    if (inside) {
      this.curLat = this.fenceLat + 0.001 // roughly 111 meters north
      this.curLon = this.fenceLon
    } else {
      this.curLat = this.fenceLat + 0.02 // roughly 2.2 kilometers north
      this.curLon = this.fenceLon
    }
    this.distance = this.haversine(this.fenceLat, this.fenceLon, this.curLat, this.curLon)
    const nowInside: boolean = this.distance <= this.fenceRadius
    this.inside = nowInside
    this.pushLog(nowInside
      ? `[模拟]已进入围栏，距离 ${this.distance.toFixed(0)}m`
      : `[模拟]已离开围栏，距离 ${this.distance.toFixed(0)}m`)
  }

  private requestPermissionThenCheck(): void {
    const atManager = abilityAccessCtrl.createAtManager()
    const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    atManager.requestPermissionsFromUser(ctx, ['ohos.permission.APPROXIMATELY_LOCATION'])
      .then(() => this.checkPosition())
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.pushLog(`权限申请被拒绝：${be.code} ${be.message}`)
      })
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('④ 地理围栏')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        Text('系统原生围栏走 gnssFenceStatusChange：它接收一个 WantAgent，触发时由系统帮你拉起 Ability，模拟器上跑不出来。所以下面先把真实 API 摊开讲，再给一个「距离判定」版本，逻辑在任何设备上都能验证。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        // ---- real API shape ----
        Column({ space: 6 }) {
          Text('系统原生 API 长这样')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .width('100%')
          Text(
            'let req: geoLocationManager.GeofenceRequest = {\n' +
            '  scenario: geoLocationManager.LocationRequestScenario.TRAJECTORY_TRACKING,\n' +
            '  geofence: {\n' +
            '    latitude: 39.9087,\n' +
            '    longitude: 116.3975,\n' +
            '    radius: 500,\n' +
            '    expiration: 3600000\n' +
            '  }\n' +
            '}\n' +
            'geoLocationManager.on(\'gnssFenceStatusChange\', req, wantAgent)'
          )
            .fontSize(11)
            .fontFamily('monospace')
            .fontColor('#d32f2f')
            .width('100%')
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#FFF8E1')
        .borderRadius(8)

        Text('字段说明：radius 是围栏半径（米），expiration 是围栏存活时间（⚠️ 单位是毫秒，不是秒，SDK 声明文件里没写单位，官方文档才写明），coordinateSystemType 缺省按 WGS84。参数不合规会抛 401。')
          .fontSize(12)
          .fontColor('#888')
          .width('100%')

        // ---- runnable check ----
        Text('可运行版本：距离判定')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ top: 8 })

        Column({ space: 6 }) {
          this.infoRow('围栏中心', `${this.fenceLat.toFixed(4)}, ${this.fenceLon.toFixed(4)}`)
          this.infoRow('围栏半径', `${this.fenceRadius} m`)
          this.infoRow('当前位置', `${this.curLat.toFixed(6)}, ${this.curLon.toFixed(6)}`)
          this.infoRow('直线距离', `${this.distance.toFixed(0)} m`)
          this.infoRow('当前状态', this.inside ? '围栏内' : '围栏外')
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)

        Button(this.loading ? '定位中…' : '获取当前位置并判定')
          .width('100%')
          .enabled(!this.loading)
          .onClick(() => this.requestPermissionThenCheck())

        Row({ space: 10 }) {
          Button('模拟进入')
            .layoutWeight(1)
            .backgroundColor('#00838F')
            .onClick(() => this.simulate(true))

          Button('模拟离开')
            .layoutWeight(1)
            .backgroundColor('#999')
            .onClick(() => this.simulate(false))
        }
        .width('100%')

        if (this.logs.length > 0) {
          Column() {
            Text('事件日志').fontSize(13).fontWeight(FontWeight.Medium).width('100%')
            ForEach(this.logs, (item: string, i: number) => {
              Text(`${i + 1}. ${item}`)
                .fontSize(12)
                .fontColor('#555')
                .width('100%')
            }, (item: string, i: number) => `${i}`)
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .alignItems(HorizontalAlign.Start)
        }

        Text('踩坑提示：判定半径必须大于返回的 accuracy（否则定位噪声会让状态来回跳）；原生围栏还要在 module.json5 配 backgroundModes 与 FenceExtensionAbility 才能后台常驻。')
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
      Text(label).fontSize(13).fontColor('#888').width(80)
      Text(value).fontSize(13).layoutWeight(1)
    }
    .width('100%')
  }
}