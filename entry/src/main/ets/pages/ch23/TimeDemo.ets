import { router } from '@kit.ArkUI'
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit'

// Time template demo: wrap business functions in hiTraceMeter spans. In the Profiler
// "Time" template these appear in the "User Trace" lane as a call tree / flame chart.
// Material §4.4 / §6: hiTraceMeter.startTrace(name, id) ... finishTrace(name, id).
@Entry
@Component
struct Ch23Time {
  @State log: string = '点击按钮运行并打点'

  // top-level functions so hiTraceMeter spans nest correctly
  runStageA(): void {
    hiTraceMeter.startTrace('StageA', 2001)
    let s: number = 0
    for (let i = 0; i < 50000000; i++) {
      s += i
    }
    hiTraceMeter.finishTrace('StageA', 2001)
  }

  runStageB(): void {
    hiTraceMeter.startTrace('StageB', 2002)
    let s: number = 0
    for (let i = 0; i < 80000000; i++) {
      s += i
    }
    hiTraceMeter.finishTrace('StageB', 2002)
  }

  runTraced(): void {
    hiTraceMeter.startTrace('Ch23Time_Root', 2000)
    this.runStageA()
    this.runStageB()
    hiTraceMeter.finishTrace('Ch23Time_Root', 2000)
    this.log = '已打点：Ch23Time_Root → StageA + StageB（见 Time 模板 User Trace 泳道）'
  }

  build() {
    Column({ space: 16 }) {
      Text('Time · 函数耗时与跨语言栈')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24 })

      Text('hiTraceMeter 打点后，在 Profiler Time 模板的 User Trace 泳道能看到调用树/火焰图')
        .fontSize(13)
        .fontColor('#666')
        .margin({ bottom: 8 })

      Text(this.log).fontSize(14).fontColor('#999')

      Button('运行并打点（嵌套 Span）').width('90%')
        .onClick(() => this.runTraced())

      Text('如需符号化的 Native/CPU Callstack，模块 build-profile.json5 设 strip: false')
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
