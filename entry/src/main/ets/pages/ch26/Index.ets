import { router } from '@kit.ArkUI';

// Chapter 26 landing page: links to the single-device KV demo and the
// distributed (cross-device) KV demo.
@Entry
@Component
struct Ch26Index {
  build() {
    Column({ space: 16 }) {
      Text('第26篇：分布式 KV Store')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('本章 demo：单设备 KV 三步读写 / 跨设备自动同步（需真机+同账号组网）')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('单设备 KV：存 / 取 / 删')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch26/SingleDeviceDemo' } as router.RouterOptions))

      Button('分布式同步：跨设备收藏夹')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch26/DistributedDemo' } as router.RouterOptions))

      Button('返回首页')
        .width('80%')
        .margin({ top: 16 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
