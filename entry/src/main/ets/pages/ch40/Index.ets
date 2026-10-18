import { router } from '@kit.ArkUI'

// Chapter 40: Sensor Kit (hardware interaction series, part 1)
//   A phone hides many hardware sensors: accelerometer, gyroscope, ambient light...
//   Subscribe with sensor.on(id, callback) and always unsubscribe with sensor.off(id).
@Entry
@Component
struct Ch40Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第40篇：传感器 Sensor Kit（硬件互动开篇）')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('手机里藏着一堆传感器：加速度、陀螺仪、光线… 应用订阅它们就能拿到实时硬件数据。这是「硬件互动」系列的第一篇。')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        // ---------- ① Accelerometer ----------
        Text('① 加速度计（小球随重力滚动 + 摇一摇）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('打开加速度计')
          .width('92%')
          .onClick(() => router.pushUrl({ url: 'pages/ch40/Ch40Accelerometer' } as router.RouterOptions))

        // ---------- ② Gyroscope ----------
        Text('② 陀螺仪（三轴角速度）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('打开陀螺仪')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch40/Ch40Gyroscope' } as router.RouterOptions))

        // ---------- ③ Ambient light ----------
        Text('③ 环境光（光照强度 lux，无需运行时权限）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('打开环境光')
          .width('92%')
          .backgroundColor('#6A1B9A')
          .onClick(() => router.pushUrl({ url: 'pages/ch40/Ch40Light' } as router.RouterOptions))

        Text('权限说明：加速度计 / 陀螺仪在真机需 ohos.permission.ACCELEROMETER / GYROSCOPE（本工程 module.json5 已声明，并运行时动态申请）；环境光为 system_grant，开箱即用。模拟器多数传感器可注入模拟数据。')
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
