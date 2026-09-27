import { taskpool } from '@kit.ArkTS'
import { router } from '@kit.ArkUI'

// CPU-bound checksum. Decorated with @Concurrent so it can run inside the task pool,
// off the main (UI) thread. Rule: a @Concurrent function must be top-level, may only
// use its parameters + local variables, and cannot touch `this` or component state.
@Concurrent
function crc32(buffer: Uint8Array): number {
  let crc: number = 0xFFFFFFFF
  for (let i: number = 0; i < buffer.length; i++) {
    crc ^= (buffer[i] & 0xFF)
    for (let j: number = 0; j < 8; j++) {
      if ((crc & 1) !== 0) {
        crc = (crc >>> 1) ^ 0xEDB88320
      } else {
        crc = crc >>> 1
      }
    }
  }
  return (crc ^ 0xFFFFFFFF) >>> 0
}

@Entry
@Component
struct Ch37TaskPoolDemo {
  @State angle: number = 0
  @State mainResult: string = '点击「主线程」体验卡顿'
  @State poolResult: string = '点击「任务池」体验顺滑'
  private spinning: boolean = true

  // Continuous spinner. When the main thread is blocked, the animation freezes —
  // that is exactly how you *see* the UI thread being starved.
  aboutToAppear(): void {
    this.spin()
  }

  aboutToDisappear(): void {
    this.spinning = false
  }

  spin(): void {
    if (!this.spinning) {
      return
    }
    this.getUIContext()?.animateTo({ duration: 1500, iterations: 1, onFinish: (): void => this.spin() }, (): void => {
      this.angle = (this.angle + 360) % 360
    })
  }

  makeData(size: number): Uint8Array {
    const buf: Uint8Array = new Uint8Array(size)
    for (let i: number = 0; i < size; i++) {
      buf[i] = (i * 31) & 0xFF
    }
    return buf
  }

  // Runs on the MAIN thread: blocks everything (UI freezes) for the whole duration.
  doMainThread(): void {
    const data: Uint8Array = this.makeData(8 * 1024 * 1024)
    const t0: number = Date.now()
    let acc: number = 0
    for (let k: number = 0; k < 3; k++) {
      acc ^= crc32(data)
    }
    const dt: number = Date.now() - t0
    this.mainResult = `主线程 3 次校验：耗时 ${dt}ms，crc=${acc.toString(16)}（期间 UI 卡死）`
  }

  // Dispatches 3 tasks to the task pool. They run on worker threads in parallel,
  // so wall-clock time ≈ 1 task and the UI stays responsive.
  async doTaskPool(): Promise<void> {
    const data: Uint8Array = this.makeData(8 * 1024 * 1024)
    const t0: number = Date.now()
    const results: number[] = (await Promise.all([
      taskpool.execute(crc32, data),
      taskpool.execute(crc32, data),
      taskpool.execute(crc32, data)
    ])) as number[]
    const dt: number = Date.now() - t0
    const acc: number = (results[0] ^ results[1] ^ results[2]) >>> 0
    this.poolResult = `任务池 3 次校验：耗时 ${dt}ms，crc=${acc.toString(16)}（UI 不卡）`
  }

  build() {
    Column({ space: 16 }) {
      Text('TaskPool 基础：主线程 vs 任务池').fontSize(22).fontWeight(FontWeight.Bold)

      // Spinner — watch it during the two tests.
      Stack({ alignContent: Alignment.Center }) {
        Row() {
          Rect({ width: 26, height: 6 }).fill('#317af7').borderRadius(3)
        }
        .rotate({ angle: this.angle })
      }
      .width(64)
      .height(64)

      Text('上面小方块持续旋转；点「主线程」时它会卡住，点「任务池」时照常转')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      Button('主线程计算（会卡顿）')
        .width('90%')
        .backgroundColor('#D32F2F')
        .onClick(() => this.doMainThread())

      Text(this.mainResult)
        .width('90%')
        .fontSize(12)
        .fontFamily('monospace')

      Button('任务池计算（顺滑）')
        .width('90%')
        .backgroundColor('#2E7D32')
        .onClick(() => this.doTaskPool())

      Text(this.poolResult)
        .width('90%')
        .fontSize(12)
        .fontFamily('monospace')

      Button('返回')
        .width('90%')
        .margin({ top: 12 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Start)
  }
}
