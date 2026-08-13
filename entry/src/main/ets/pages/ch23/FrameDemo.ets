import { router } from '@kit.ArkUI'
import { taskpool } from '@kit.ArkTS'

// Frame template demo: heavy compute on the main thread causes jank; offloading to
// TaskPool keeps the UI responsive. Record with the Profiler "Frame" template.
// Material §5: main-thread compute -> migrate to TaskPool / Worker.
// NOTE: a function passed to taskpool MUST be decorated with @Concurrent, and it must
// be a top-level ordinary function (no capturing of outer scope / this).
@Concurrent
function ch23HeavyCompute(): number {
  let c: number = 0
  while (c < 200000000) {
    c++
  }
  return c
}

@Entry
@Component
struct Ch23Frame {
  @State status: string = '空闲'
  @State result: number = 0

  // BAD: runs on the main UI thread, blocks rendering -> AppDeadlineMissed jank.
  runOnMainThread(): void {
    this.status = '主线程计算中（此时滑动/点按钮会卡）'
    const r: number = ch23HeavyCompute()
    this.result = r
    this.status = '主线程计算完成'
  }

  // GOOD: offloads to TaskPool, UI stays responsive.
  async runOnTaskPool(): Promise<void> {
    this.status = 'TaskPool 计算中（UI 仍可操作）'
    const task: taskpool.Task = new taskpool.Task(ch23HeavyCompute)
    const r: number = await taskpool.execute(task) as number
    this.result = r
    this.status = 'TaskPool 计算完成'
  }

  build() {
    Column({ space: 16 }) {
      Text('Frame · 丢帧/卡顿分析')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24 })

      Text('点「主线程计算」后用 Profiler Frame 模板录，会看到 AppDeadlineMissed 卡顿；TaskPool 版无卡顿')
        .fontSize(13)
        .fontColor('#666')
        .margin({ bottom: 8 })

      Text(this.status).fontSize(15)
      Text(`结果: ${this.result}`).fontSize(15)

      Button('主线程计算（制造卡顿）').width('90%')
        .onClick(() => this.runOnMainThread())
      Button('TaskPool 计算（保持流畅）').width('90%')
        .onClick(() => this.runOnTaskPool())

      Text('另：长列表请用 LazyForEach + @Reusable（见第16篇），减少布局与组件更新开销')
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
