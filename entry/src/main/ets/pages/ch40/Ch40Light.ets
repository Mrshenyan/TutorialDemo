import { router } from '@kit.ArkUI'
import { sensor } from '@kit.SensorServiceKit'

interface BizErr { code: number; message: string }

// ③ Ambient light: show illuminance in lux.
//   LightResponse carries { intensity } in lux. Ambient light is system_grant, no runtime permission needed.
@Entry
@Component
struct Ch40Light {
  @State lux: number = 0
  @State log: string = '用手遮住手机顶部光线传感器，数值会下降'

  private lightCb: (data: sensor.LightResponse) => void = (data: sensor.LightResponse) => {
    this.lux = data.intensity
  }

  private startListen(): void {
    try {
      sensor.on(sensor.SensorId.AMBIENT_LIGHT, this.lightCb)
    } catch (e) {
      const be: BizErr = e as BizErr
      this.log = `订阅失败[${be.code}]：${be.message}`
    }
  }

  private stopListen(): void {
    sensor.off(sensor.SensorId.AMBIENT_LIGHT, this.lightCb)
  }

  aboutToAppear(): void {
    this.startListen()
  }

  aboutToDisappear(): void {
    this.stopListen()
  }

  build() {
    Column({ space: 14 }) {
      Text('③ 环境光 Ambient Light')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      Text('intensity 单位 lux；环境光为 system_grant，无需运行时申请权限')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      Text(`${this.lux.toFixed(1)} lux`)
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#6A1B9A')

      // A bar that grows with illuminance (capped at 1000 lux for display).
      Row() {
        Column()
          .width(`${Math.min(this.lux / 1000 * 100, 100)}%`)
          .height(16)
          .backgroundColor('#6A1B9A')
      }
      .width('90%')
      .height(16)
      .backgroundColor('#eeeeee')
      .borderRadius(8)

      Text(this.log)
        .fontSize(13)
        .fontColor('#444')
        .width('90%')
        .fontFamily('monospace')

      Button('停止订阅')
        .width('90%')
        .backgroundColor('#999')
        .onClick(() => this.stopListen())

      Button('返回')
        .width('90%')
        .margin({ top: 8 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Start)
  }
}
