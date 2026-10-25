import { router } from '@kit.ArkUI'
import { hiAppEvent } from '@kit.PerformanceAnalysisKit'

interface BizErr { code: number; message: string }

// Chapter 45 demo 3 - hiAppEvent: structured events + system fault subscription.
//
// Two superpowers over plain hilog:
//   1. write(): your own structured events (buy_click, level_finish ...) with
//      typed params - queryable and aggregatable later.
//   2. addWatcher(): subscribe to SYSTEM events - APP_CRASH, APP_FREEZE,
//      CPU_USAGE_HIGH ... The crash report survives the crash itself, so a
//      watcher registered on next launch receives it. That is the closest
//      thing to "online issue location" you can do without a backend.
//
// Gotcha: system events are only reported when the matching policy is
// switched on via configEventPolicy(). A watcher that receives nothing is
// almost always missing its policy.
@Entry
@Component
struct Ch45AppEvent {
  @State output: string = '打点后，系统事件会在下次启动时补发'
  @State events: string[] = []
  @State policyOn: boolean = false

  private domain: string = 'tutorial_demo'
  private watcher: hiAppEvent.Watcher | null = null

  aboutToAppear(): void {
    this.addWatch()
  }

  aboutToDisappear(): void {
    this.removeWatch()
  }

  // OS-domain filter: crash, freeze and CPU spikes are the three you check
  // first on any "user says it's laggy/stuck" report.
  private addWatch(): void {
    const w: hiAppEvent.Watcher = {
      name: 'ch45Watcher',
      appEventFilters: [
        {
          domain: hiAppEvent.domain.OS,
          names: [
            hiAppEvent.event.APP_CRASH,
            hiAppEvent.event.APP_FREEZE,
            hiAppEvent.event.CPU_USAGE_HIGH,
            hiAppEvent.event.APP_LAUNCH
          ]
        }
      ],
      onReceive: (domain: string, groups: Array<hiAppEvent.AppEventGroup>) => {
        const fresh: string[] = []
        groups.forEach((g: hiAppEvent.AppEventGroup) => {
          g.appEventInfos.forEach((info: hiAppEvent.AppEventInfo) => {
            fresh.push(`[${info.name}] ${JSON.stringify(info.params)}`)
          })
        })
        if (fresh.length > 0) {
          // Reassign instead of push so the @State array reference changes and
          // ArkUI definitely re-renders.
          this.events = this.events.concat(fresh)
          this.output = `收到 ${this.events.length} 条系统事件`
        }
      }
    }
    this.watcher = w
    hiAppEvent.addWatcher(w)
  }

  private removeWatch(): void {
    if (this.watcher !== null) {
      hiAppEvent.removeWatcher(this.watcher)
      this.watcher = null
    }
  }

  // Custom event. params must be a structured object: number/string/bool/
  // string[] are the supported types.
  private writeEvent(): void {
    const info: hiAppEvent.AppEventInfo = {
      domain: this.domain,
      name: 'ch45_demo_click',
      eventType: hiAppEvent.EventType.BEHAVIOR,
      params: {
        button: 'write_event',
        count: this.events.length + 1,
        ok: true
      }
    }
    hiAppEvent.write(info)
      .then(() => {
        this.output = '自定义事件已写入（BEHAVIOR 类型，domain=tutorial_demo）'
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.output = `打点失败 [${be.code}] ${be.message}`
      })
  }

  // Passing a policy object is what switches the corresponding collection ON
  // - the fields are thresholds/options, not booleans. Crash/freeze policies
  // additionally attach the page-switch trail, which is exactly the
  // "what was the user doing" context you want in a crash report.
  private openPolicy(): void {
    const policy: hiAppEvent.EventPolicy = {
      appCrashPolicy: { pageSwitchLogEnable: true },
      appFreezePolicy: { pageSwitchLogEnable: true },
      cpuUsageHighPolicy: { foregroundLoadThreshold: 90 }
    }
    hiAppEvent.configEventPolicy(policy)
      .then(() => {
        this.policyOn = true
        this.output = '策略已开启：崩溃/卡死/CPU 高占用事件开始被系统记录'
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.output = `开启策略失败 [${be.code}] ${be.message}`
      })
  }

  // Fire an uncaught exception on purpose. The process dies, the OS writes an
  // APP_CRASH event, and the watcher on next launch receives it - including
  // the exception name, message and the page it happened on.
  private crashDemo(): void {
    this.output = '即将崩溃，重启 App 后本页自动收到 APP_CRASH 事件'
    setTimeout(() => {
      throw new Error('ch45 crash demo')
    }, 300)
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('③ hiAppEvent：打点与系统事件订阅')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 12 })

        Text('自定义事件打点 + 订阅系统故障事件（崩溃/卡死/CPU 高）。崩溃事件由系统记录，下次启动 watcher 会补发——这是没有后端也能做「线上定位」的最近路径。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        Button('打一条自定义事件（write）')
          .width('100%')
          .onClick(() => this.writeEvent())

        Button(this.policyOn ? '策略已开启 ✓' : '开启崩溃/卡死/CPU 策略（configEventPolicy）')
          .width('100%')
          .backgroundColor(this.policyOn ? '#2E7D32' : '#B26A00')
          .onClick(() => this.openPolicy())

        Button('模拟一次崩溃（看看 APP_CRASH 事件）')
          .width('100%')
          .backgroundColor('#C5221F')
          .onClick(() => this.crashDemo())

        Text(this.output)
          .fontSize(12)
          .fontColor('#317af7')
          .width('100%')
          .padding(8)
          .backgroundColor('#EEF4FF')
          .borderRadius(6)

        Text(`收到的事件（${this.events.length} 条）：`)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ top: 6 })

        if (this.events.length === 0) {
          Text('（watcher 已注册。先开启策略，点一次模拟崩溃，重启 App 再进本页）')
            .fontSize(12)
            .fontColor('#888')
            .width('100%')
        } else {
          ForEach(this.events, (ev: string) => {
            Text(ev)
              .fontSize(11)
              .fontFamily('monospace')
              .width('100%')
              .padding(6)
              .backgroundColor('#F5F7F9')
              .borderRadius(4)
          }, (ev: string) => ev)
        }

        Text('注意 import 路径：必须 @ohos.hiviewdfx.hiAppEvent（经 @kit.PerformanceAnalysisKit 导出），旧路径 @ohos.hiAppEvent 自 API 9 已废弃，大量旧教程还在用它。')
          .fontSize(12)
          .fontColor('#B26A00')
          .width('100%')
          .padding(10)
          .backgroundColor('#FFF8E5')
          .borderRadius(8)

        Button('返回')
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => router.back())
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
  }
}
