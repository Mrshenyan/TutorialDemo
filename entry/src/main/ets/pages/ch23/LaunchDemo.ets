import { router } from '@kit.ArkUI'
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit'

// Launch template demo: show how synchronous heavy work in aboutToAppear delays first frame.
// Reproduce: record with the Profiler "Launch" template on a real device + debug build.
// Material §6.1: moving lifecycle compute to async cut AbilityStage 2.2s -> 220ms.
@Entry
@Component
struct Ch23Launch {
  @State optimize: boolean = false      // false = block UI thread; true = defer to async
  @State firstFrameMs: number = 0       // proxy metric: aboutToAppear start -> work done
  @State hint: string = '点「重新走启动路径」对比两种模式'
  private startTime: number = 0

  aboutToAppear(): void {
    this.runStartup()
  }

  // Shared by aboutToAppear and the "restart" button so the demo is reproducible.
  runStartup(): void {
    this.startTime = Date.now()
    hiTraceMeter.startTrace('Ch23Launch_Startup', 1001)
    if (this.optimize) {
      // OPTIMIZED: keep the heavy work off the critical first-frame path.
      setTimeout(() => {
        this.heavyWork()
        hiTraceMeter.finishTrace('Ch23Launch_Startup', 1001)
        this.firstFrameMs = Date.now() - this.startTime
        this.hint = '优化模式：重活在 setTimeout 后执行，首帧不被阻塞'
      }, 0)
    } else {
      // BAD: block the UI thread during startup -> long First Frame in Launch template.
      this.heavyWork()
      hiTraceMeter.finishTrace('Ch23Launch_Startup', 1001)
      this.firstFrameMs = Date.now() - this.startTime
      this.hint = '阻塞模式：重活在 aboutToAppear 同步执行，首帧被拖慢'
    }
  }

  // ~200M iterations of busy work (material §6.1 computeTask).
  heavyWork(): void {
    let c: number = 0
    while (c < 200000000) {
      c++
    }
  }

  build() {
    Column({ space: 16 }) {
      Text('Launch · 冷启动分析')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24 })

      Text('hiTraceMeter 已对启动路径打点，可在 Time 模板 User Trace 泳道查看')
        .fontSize(13)
        .fontColor('#666')
        .margin({ bottom: 8 })

      Row({ space: 12 }) {
        Text('优化模式（异步）').fontSize(16)
        Toggle({ isOn: this.optimize, type: ToggleType.Switch })
          .onChange((v: boolean) => { this.optimize = v })
      }

      Text(`首帧可见耗时(近似): ${this.firstFrameMs} ms`).fontSize(16)
      Text(this.hint).fontSize(13).fontColor('#999')

      Button('重新走启动路径')
        .width('90%')
        .onClick(() => this.runStartup())

      Text('真实测量请用 Profiler Launch 模板看五阶段耗时 / Load ETS Files')
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
