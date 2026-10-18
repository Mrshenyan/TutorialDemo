import { router } from '@kit.ArkUI'
import { abilityAccessCtrl, common } from '@kit.AbilityKit'
import { geoLocationManager } from '@kit.LocationKit'

interface BizErr { code: number; message: string }

// ③ Reverse geocoding: coordinates -> readable address.
//   getAddressesFromLocation() needs network access. Without INTERNET permission
//   the promise rejects with LOCATING_FAILED_INTERNET_ACCESS_FAILURE (-5).
@Entry
@Component
struct Ch41ReverseGeo {
  @State lat: number = 39.9042 // default: Tiananmen, so the demo still shows something
  @State lon: number = 116.4074
  @State placeName: string = ''
  @State country: string = ''
  @State province: string = ''
  @State city: string = ''
  @State district: string = ''
  @State road: string = ''
  @State postal: string = ''
  @State locale: string = ''
  @State status: string = '点击按钮查询地址'
  @State loading: boolean = false

  private reverseGeo(): void {
    this.loading = true
    this.status = '查询中…'
    // locale controls the language of the returned address strings.
    let req: geoLocationManager.ReverseGeoCodeRequest = {
      locale: 'zh-Hans-CN',
      latitude: this.lat,
      longitude: this.lon,
      maxItems: 1
    }
    geoLocationManager.getAddressesFromLocation(req)
      .then((addrs: Array<geoLocationManager.GeoAddress>) => {
        this.loading = false
        if (addrs.length === 0) {
          this.status = '未查到地址（该点可能没有数据）'
          return
        }
        // Every GeoAddress field is optional, so read them defensively.
        const a: geoLocationManager.GeoAddress = addrs[0]
        this.placeName = a.placeName ?? '-'
        this.country = a.countryName ?? '-'
        this.province = a.administrativeArea ?? '-'
        this.city = a.locality ?? '-'
        this.district = a.subLocality ?? '-'
        this.road = a.roadName ?? '-'
        this.postal = a.postalCode ?? '-'
        this.locale = a.locale ?? '-'
        this.status = '查询成功'
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.loading = false
        this.status = `查询失败[${be.code}]：${be.message}`
      })
  }

  private locateThenReverse(): void {
    const atManager = abilityAccessCtrl.createAtManager()
    const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    atManager.requestPermissionsFromUser(ctx, ['ohos.permission.APPROXIMATELY_LOCATION'])
      .then(() => {
        let req: geoLocationManager.CurrentLocationRequest = {
          priority: geoLocationManager.LocationRequestPriority.ACCURACY,
          timeoutMs: 10000
        }
        geoLocationManager.getCurrentLocation(req)
          .then((loc: geoLocationManager.Location) => {
            this.lat = loc.latitude
            this.lon = loc.longitude
            this.reverseGeo()
          })
          .catch((e: BizErr) => {
            const be: BizErr = e as BizErr
            this.loading = false
            this.status = `定位失败[${be.code}]：${be.message}`
          })
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.status = `权限申请被拒绝：${be.code} ${be.message}`
      })
  }

  // Row builder reused by the address table.
  @Builder
  private infoRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(13).fontColor('#888').width(90)
      Text(value).fontSize(13).layoutWeight(1)
    }
    .width('100%')
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('③ 逆地理编码')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        Text('把经纬度翻译成人能读的地址。注意这个接口要联网：需要 ohos.permission.INTERNET（本工程已声明）。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        Button(this.loading ? '查询中…' : '定位并查询地址')
          .width('100%')
          .enabled(!this.loading)
          .onClick(() => this.locateThenReverse())

        Button('直接查询默认坐标（39.9042, 116.4074）')
          .width('100%')
          .backgroundColor('#6A1B9A')
          .onClick(() => this.reverseGeo())

        Column({ space: 8 }) {
          this.infoRow('坐标', `${this.lat.toFixed(6)}, ${this.lon.toFixed(6)}`)
          Divider()
          this.infoRow('地点名', this.placeName)
          Divider()
          this.infoRow('国家', this.country)
          Divider()
          this.infoRow('省/直辖市', this.province)
          Divider()
          this.infoRow('城市', this.city)
          Divider()
          this.infoRow('区县', this.district)
          Divider()
          this.infoRow('道路', this.road)
          Divider()
          this.infoRow('邮编', this.postal)
          Divider()
          this.infoRow('语言标记', this.locale)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)

        Text(this.status)
          .fontSize(13)
          .fontColor(this.loading ? '#317af7' : '#2E7D32')
          .width('100%')

        Text('踩坑提示：GeoAddress 的字段全是可选的，直接点成员可能拿到 undefined，展示前务必兜底（本章用 ?? \'-\'）。')
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