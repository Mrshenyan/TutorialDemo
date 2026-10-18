import { router } from '@kit.ArkUI'
import { abilityAccessCtrl, common } from '@kit.AbilityKit'
import { sensor } from '@kit.SensorServiceKit'

interface BizErr { code: number; message: string }

// ② Gyroscope: show 3-axis angular velocity (rad/s).
//   GyroscopeResponse carries { x, y, z } in rad/s.
@Entry
@Component
struct Ch40Gyroscope {
  @State x: number = 0
  @State y: number = 0
  @State z: number = 0
  @State log: string = '绕任意轴转动手机，看三轴角速度变化'

  private gyroCb: (data: sensor.GyroscopeResponse) => void = (data: sensor.GyroscopeResponse) => {
    this.x = data.x
    this.y = data.y
    this.z = data.z
  }

  private startListen(): void {
    try {
      sensor.on(sensor.SensorId.GYROSCOPE, this.gyroCb)
    } catch (e) {
      const be: BizErr = e as BizErr
      this.log = `订阅失败[${be.code}]：${be.message}`
    }
  }

  private stopListen(): void {
    sensor.off(sensor.SensorId.GYROSCOPE, this.gyroCb)
  }

  private requestPermissionThenListen(): void {
    const atManager = abilityAccessCtrl.createAtManager()
    const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    atManager.requestPermissionsFromUser(ctx, ['ohos.permission.GYROSCOPE'])
      .then(() => this.startListen())
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.log = `权限申请结果：${be.code} ${be.message}（仍尝试订阅）`
        this.startListen()
      })
  }

  aboutToAppear(): void {
    this.requestPermissionThenListen()
  }

  aboutToDisappear(): void {
    this.stopListen()
  }

  build() {
    Column({ space: 14 }) {
      Text('② 陀螺仪 Gyroscope')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      Text('x / y / z 单位 rad/s，表示绕三轴的旋转角速度')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      Text(`角速度 x = ${this.x.toFixed(3)}`)
        .fontSize(15)
        .fontFamily('monospace')
        .width('90%')
        .textAlign(TextAlign.Start)

      Text(`角速度 y = ${this.y.toFixed(3)}`)
        .fontSize(15)
        .fontFamily('monospace')
        .width('90%')
        .textAlign(TextAlign.Start)

      Text(`角速度 z = ${this.z.toFixed(3)}`)
        .fontSize(15)
        .fontFamily('monospace')
        .width('90%')
        .textAlign(TextAlign.Start)

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
