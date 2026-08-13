import { router } from '@kit.ArkUI'

// Allocation template demo: repeatedly allocate large buffers and keep references so the
// heap keeps growing. Record with the Profiler "Allocation" template to see Native/ArkTS
// Heap climb. Release the references so GC can reclaim. Material §6.5 (PixelMap.release).
@Entry
@Component
struct Ch23Allocation {
  @State allocatedMB: number = 0
  @State leakedCount: number = 0
  // Teaching instrument: holds references so they are NOT garbage-collected (leak).
  private leaked: ArrayBuffer[] = []

  // BAD: push 50MB buffers and keep them -> heap climbs every tap.
  leakOnce(): void {
    const buf: ArrayBuffer = new ArrayBuffer(50 * 1024 * 1024) // 50 MB
    this.leaked.push(buf)
    this.leakedCount += 1
    this.allocatedMB = this.leakedCount * 50
  }

  // GOOD: drop all references -> memory becomes reclaimable.
  releaseAll(): void {
    this.leaked = []
    this.leakedCount = 0
    this.allocatedMB = 0
  }

  aboutToDisappear(): void {
    this.leaked = []   // free on page leave
  }

  build() {
    Column({ space: 16 }) {
      Text('Allocation · 内存分配')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24 })

      Text('反复点「泄漏分配」，在 Profiler Allocation 模板看 Native/ArkTS Heap 持续上涨；「释放」后回落')
        .fontSize(13)
        .fontColor('#666')
        .margin({ bottom: 8 })

      Text(`已持有: ${this.leakedCount} 块 ≈ ${this.allocatedMB} MB`).fontSize(16)

      Button('泄漏分配（+50MB，不释放）').width('90%')
        .onClick(() => this.leakOnce())
      Button('释放全部引用').width('90%')
        .onClick(() => this.releaseAll())

      Text('真实图片场景请用 PixelMap.release()（见文章 §6.5）；点几次即可，勿真到 OOM')
        .fontSize(12)
        .fontColor('#999')

      Button('返回').width('90%').margin({ top: 8 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
