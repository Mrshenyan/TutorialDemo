import { router } from '@kit.ArkUI'

// Chapter 37: Concurrency (TaskPool / Worker) + File management.
//   ① TaskPool basics     — main-thread freeze vs task-pool smoothness
//   ② File batch demo     — sandbox dirs + concurrent CRC32 checksum of real files
//   ③ Worker demo         — long-lived thread with live progress reporting
// CPU-bound work (checksum / parse / compress) is exactly what must leave the UI thread.
@Entry
@Component
struct Ch37Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第37篇：并发编程 TaskPool/Worker 与文件批量处理')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('主线程不能卡 → TaskPool 跑一次性任务；Worker 跑长驻通信；文件批量校验是典型 CPU 密集场景')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        // ---------- ① TaskPool basics ----------
        Text('① TaskPool 基础（主线程 vs 任务池）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('主线程卡顿 vs 任务池顺滑')
          .width('92%')
          .onClick(() => router.pushUrl({ url: 'pages/ch37/Ch37TaskPoolDemo' } as router.RouterOptions))

        // ---------- ② File batch ----------
        Text('② 文件批量处理（沙箱 + 并发校验）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('沙箱写文件 + TaskPool 并发校验')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch37/Ch37FileBatchDemo' } as router.RouterOptions))

        // ---------- ③ Worker ----------
        Text('③ Worker 常驻线程（进度回传）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('Worker 长任务 + 实时进度')
          .width('92%')
          .backgroundColor('#6A1B9A')
          .onClick(() => router.pushUrl({ url: 'pages/ch37/Ch37WorkerDemo' } as router.RouterOptions))

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
