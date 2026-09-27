import { worker } from '@kit.ArkTS'
import { router } from '@kit.ArkUI'

interface WorkerMsg {
  type: string
  value: number
}

@Entry
@Component
struct Ch37WorkerDemo {
  @State progress: number = 0
  @State result: string = '点击「启动 Worker」开始长任务'
  @State running: boolean = false
  private wk: worker.ThreadWorker | null = null

  aboutToAppear(): void {
    this.wk = new worker.ThreadWorker('entry/ets/workers/Ch37Worker.ets', { name: 'Ch37Worker' })
    this.wk.onmessage = (e): void => {
      const msg: WorkerMsg = e.data as WorkerMsg
      if (msg.type === 'progress') {
        this.progress = msg.value
      } else if (msg.type === 'done') {
        this.running = false
        this.result = `Worker 完成，结果=${msg.value.toFixed(2)}`
      }
    }
  }

  aboutToDisappear(): void {
    if (this.wk) {
      this.wk.terminate()
    }
  }

  start(): void {
    if (!this.wk) {
      return
    }
    this.running = true
    this.progress = 0
    this.result = 'Worker 计算中…'
    // Send the workload size; the worker reports progress and the final result.
    this.wk.postMessage(50 * 1000 * 1000)
  }

  build() {
    Column({ space: 16 }) {
      Text('Worker 常驻线程（进度回传）').fontSize(22).fontWeight(FontWeight.Bold)

      Text('TaskPool 适合「一次性任务」；Worker 适合「长驻 + 持续通信」。这里用 Worker 跑长任务并实时回传进度')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      Progress({ value: this.progress, total: 100 }).width('90%')

      Button(this.running ? '计算中…' : '启动 Worker')
        .width('90%')
        .backgroundColor('#6A1B9A')
        .enabled(!this.running)
        .onClick(() => this.start())

      Text(this.result).width('90%').fontSize(12).fontFamily('monospace')

      Button('返回').width('90%').margin({ top: 12 }).onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Start)
  }
}
