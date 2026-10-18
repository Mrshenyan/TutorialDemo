import { router } from '@kit.ArkUI'
import { abilityAccessCtrl, common } from '@kit.AbilityKit'
import { sensor } from '@kit.SensorServiceKit'

interface BizErr { code: number; message: string }

// ① Accelerometer: show x/y/z, a ball that rolls under "gravity", and shake detection.
//   AccelerometerResponse carries { x, y, z } in m/s².
@Entry
@Component
struct Ch40Accelerometer {
  @State x: number = 0
  @State y: number = 0
  @State z: number = 0
  @State ballX: number = 0 // px offset of the ball inside the track area
  @State ballY: number = 0
  @State shakeLog: string = '用力摇一摇手机试试（瞬时加速度模长 > 18 触发）'

  // Keep one stable callback reference so sensor.off() can unsubscribe it exactly.
  private accCb: (data: sensor.AccelerometerResponse) => void = (data: sensor.AccelerometerResponse) => {
    this.x = data.x
    this.y = data.y
    this.z = data.z
    // Map acceleration to a small on-screen ball offset (invert y for natural feel).
    this.ballX = data.x * 12
    this.ballY = -data.y * 12
    // Shake detection: total acceleration magnitude far above 1g (~9.8 m/s²).
    const mag: number = Math.sqrt(data.x * data.x + data.y * data.y + data.z * data.z)
    if (mag > 18) {
      this.shakeLog = `摇到了！瞬时加速度模长 = ${mag.toFixed(1)} m/s²`
    }
  }

  private startListen(): void {
    try {
      sensor.on(sensor.SensorId.ACCELEROMETER, this.accCb)
    } catch (e) {
      const be: BizErr = e as BizErr
      this.shakeLog = `订阅失败[${be.code}]：${be.message}`
    }
  }

  private stopListen(): void {
    sensor.off(sensor.SensorId.ACCELEROMETER, this.accCb)
  }

  // Accelerometer is a user_grant permission on real devices; request it, then subscribe.
  // On the simulator it may be system_grant, so we still try to listen after a failure.
  private requestPermissionThenListen(): void {
    const atManager = abilityAccessCtrl.createAtManager()
    const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    atManager.requestPermissionsFromUser(ctx, ['ohos.permission.ACCELEROMETER'])
      .then(() => this.startListen())
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.shakeLog = `权限申请结果：${be.code} ${be.message}（仍尝试订阅）`
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
      Text('① 加速度计 Accelerometer')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      Text('x / y / z 单位 m/s²；下方小球随重力偏移，摇一摇触发提示')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      // Ball rolling track.
      Stack() {
        Circle({ width: 48, height: 48 })
          .fill('#317af7')
          .position({ x: this.ballX + 130, y: this.ballY + 80 })
      }
      .width('90%')
      .height(200)
      .backgroundColor('#F2F2F2')
      .borderRadius(8)

      Text(`x=${this.x.toFixed(2)}  y=${this.y.toFixed(2)}  z=${this.z.toFixed(2)}`)
        .fontSize(15)
        .fontFamily('monospace')

      Text(this.shakeLog)
        .fontSize(13)
        .fontColor('#d32f2f')
        .width('90%')

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
