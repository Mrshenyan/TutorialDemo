import { router } from '@kit.ArkUI'

// Chapter 23 landing page: the 6 key Profiler templates, each with a reproducible demo.
// The remaining 7 templates (ComMemory / Energy / Network / Concurrency / GPU / ArkWeb / CPU)
// are covered as lookup tables in the article, not as separate demos here.
// NOTE: Profiler records only on a REAL DEVICE with a DEBUG build; the emulator is not supported.
@Entry
@Component
struct Ch23Index {
  build() {
    Column({ space: 12 }) {
      Text('第23篇：性能调优 · DevEco Profiler')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 4 })

      Text('工具 + 实战：6 个可复现场景对应 6 个重点模板；其余模板见文章查表')
        .fontSize(13)
        .fontColor('#666')
        .margin({ bottom: 8 })

      Text('⚠️ Profiler 必须真机 + debug 版本录制，模拟器不可用')
        .fontSize(13)
        .fontColor('#B26A00')
        .margin({ bottom: 8 })

      Button('1. Launch · 冷启动分析').width('90%')
        .onClick(() => router.pushUrl({ url: 'pages/ch23/LaunchDemo' }))
      Button('2. Frame · 丢帧/卡顿分析').width('90%')
        .onClick(() => router.pushUrl({ url: 'pages/ch23/FrameDemo' }))
      Button('3. ArkUI · 组件耗时与状态刷新').width('90%')
        .onClick(() => router.pushUrl({ url: 'pages/ch23/ArkUIDemo' }))
      Button('4. Time · 函数耗时与跨语言栈').width('90%')
        .onClick(() => router.pushUrl({ url: 'pages/ch23/TimeDemo' }))
      Button('5. Allocation · 内存分配').width('90%')
        .onClick(() => router.pushUrl({ url: 'pages/ch23/AllocationDemo' }))
      Button('6. Snapshot · ArkTS 堆快照/泄漏').width('90%')
        .onClick(() => router.pushUrl({ url: 'pages/ch23/SnapshotDemo' }))

      Button('返回首页').width('90%').margin({ top: 8 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
