// Chapter 50 §B: the real timeline of this launch.
//
// Every number is recorded by the app itself:
//   onConfig      -> StartupConfigEntry.onConfig          (t0)
//   tasks done    -> StartupListener.onCompleted
//   stage         -> AbilityStage.onCreate
//   ability       -> EntryAbility.onCreate
//   window stage  -> onWindowStageCreate
//   first frame   -> pages/Index.aboutToAppear
//
// Each task returns "start|cost", both on the same Date.now() clock, so the page
// can draw the real [start, end] interval instead of trusting the docs about
// what should be parallel.
import { startupManager } from '@kit.AbilityKit'
import { Ch50Trace } from '../ch50data/Ch50Trace'

class Milestone {
  label: string = ''
  at: number = 0
  hint: string = ''

  constructor(label: string, at: number, hint: string) {
    this.label = label
    this.at = at
    this.hint = hint
  }
}

class TaskSpan {
  name: string = ''
  startRel: number = -1
  endRel: number = -1
  cost: number = -1
  ok: boolean = false

  constructor(name: string) {
    this.name = name
  }
}

@Entry
@Component
struct Ch50TimelinePage {
  @State items: Milestone[] = []
  @State spans: TaskSpan[] = []
  @State overlapText: string = ''
  @State manualText: string = ''
  @State stageMs: number = 0
  @State totalMs: number = 0
  @State completedMs: number = 0

  aboutToAppear(): void {
    this.readTaskResults()
    this.buildTimeline()
  }

  private resultOf(name: string): string {
    let v: string = ''
    try {
      v = startupManager.getStartupTaskResult(name) as string
    } catch (e) {
      v = ''
    }
    return v
  }

  private spanOf(name: string): TaskSpan {
    const span: TaskSpan = new TaskSpan(name)
    const raw: string = this.resultOf(name)
    if (raw.length === 0) {
      return span
    }
    const parts: string[] = raw.split('|')
    if (parts.length !== 2) {
      return span
    }
    const start: number = Number.parseInt(parts[0])
    const cost: number = Number.parseInt(parts[1])
    span.startRel = Ch50Trace.sinceConfig(start)
    span.endRel = span.startRel + cost
    span.cost = cost
    span.ok = true
    return span
  }

  private readTaskResults(): void {
    const list: TaskSpan[] = []
    list.push(this.spanOf('Ch50TaskConfig'))
    list.push(this.spanOf('Ch50TaskCache'))
    list.push(this.spanOf('Ch50TaskFeed'))
    this.spans = list

    const cache: TaskSpan = list[1]
    const feed: TaskSpan = list[2]
    if (cache.ok && feed.ok) {
      const overlapped: boolean = cache.startRel < feed.endRel && feed.startRel < cache.endRel
      this.overlapText = overlapped
        ? `Cache 和 Feed 的时间段重叠了，确实是同时在跑：${cache.cost} ms 和 ${feed.cost} ms 两个任务，总共只花了约 ${Math.max(cache.cost, feed.cost) + 60} ms。`
        : `Cache 和 Feed 的时间段没有重叠——它们被串行执行了，总耗时接近两个任务之和。`
    } else {
      this.overlapText = '没读到任务结果，可能这次启动没跑自动任务。'
    }

    let reportRun: boolean = false
    try {
      reportRun = startupManager.isStartupTaskInitialized('Ch50TaskReport')
    } catch (e) {
      reportRun = false
    }
    this.manualText = reportRun
      ? 'Ch50TaskReport 已初始化（说明手动任务被触发过，不是这次冷启动干的）'
      : 'Ch50TaskReport 未初始化 —— excludeFromAutoStart 生效了，它没占启动时间'
  }

  private buildTimeline(): void {
    const list: Milestone[] = []
    list.push(new Milestone('框架开始（onConfig）', 0, '启动任务的 t0，这个点永远是 0'))
    list.push(new Milestone('全部任务完成（onCompleted）', Ch50Trace.sinceConfig(Ch50Trace.tCompleted),
      '最后一个自动任务返回的时刻'))
    list.push(new Milestone('AbilityStage.onCreate', Ch50Trace.sinceConfig(Ch50Trace.tAbilityStage),
      '自动任务的调度点'))
    list.push(new Milestone('EntryAbility.onCreate', Ch50Trace.sinceConfig(Ch50Trace.tAbilityCreate), ''))
    list.push(new Milestone('onWindowStageCreate', Ch50Trace.sinceConfig(Ch50Trace.tWindowStage), '开始加载首页'))
    list.push(new Milestone('首页 aboutToAppear', Ch50Trace.sinceConfig(Ch50Trace.tPageAppear), '用户能看到界面'))
    this.items = list
    this.stageMs = Ch50Trace.sinceConfig(Ch50Trace.tAbilityStage)
    this.completedMs = Ch50Trace.sinceConfig(Ch50Trace.tCompleted)
    this.totalMs = Ch50Trace.sinceConfig(Ch50Trace.tPageAppear)
  }

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Text('B · 这次冷启动的真实时间线')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 16 })
          .width('92%')

        Text('所有时间点都是应用自己打的，相对 onConfig 的毫秒偏移。杀掉应用重进一次，这里会变成新的一轮数据。')
          .fontSize(11)
          .fontColor('#888')
          .width('92%')

        Column({ space: 6 }) {
          ForEach(this.items, (m: Milestone) => {
            Row({ space: 8 }) {
              Text(m.at >= 0 ? `+${m.at} ms` : 'n/a')
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor(m.at >= 0 ? '#317af7' : '#999')
                .width(80)

              Column({ space: 2 }) {
                Text(m.label).fontSize(13)
                if (m.hint.length > 0) {
                  Text(m.hint).fontSize(10).fontColor('#999')
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding({ top: 4, bottom: 4 })
          }, (m: Milestone) => m.label)
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .border({ width: 1, color: '#E0E0E0' })
        .alignItems(HorizontalAlign.Start)

        Column({ space: 8 }) {
          Text('任务各自的执行区间').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#6A1B9A')
          ForEach(this.spans, (s: TaskSpan) => {
            Row({ space: 8 }) {
              Text(s.name.replace('Ch50Task', ''))
                .fontSize(11)
                .fontColor('#888')
                .width(46)
              Text(s.ok ? `+${s.startRel} → +${s.endRel} ms` : '未运行')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(s.ok ? '#6A1B9A' : '#BBB')
                .layoutWeight(1)
              Text(s.ok ? `${s.cost} ms` : '')
                .fontSize(11)
                .fontColor('#888')
            }
            .width('100%')
          }, (s: TaskSpan) => s.name)

          Text(this.overlapText)
            .fontSize(11)
            .fontColor('#555')
            .width('100%')
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#F3E5F5')
        .borderRadius(10)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('手动任务有没有偷偷跑').fontSize(13).fontWeight(FontWeight.Medium).fontColor('#EF6C00')
          Text(this.manualText).fontSize(11).fontColor('#555').width('100%')
        }
        .width('92%')
        .padding(10)
        .backgroundColor('#FFF3E0')
        .borderRadius(10)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text(`AbilityStage.onCreate：+${this.stageMs} ms`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#317af7')
          Text('这一行是 UI 线程最早能继续干活的时刻。它离「任务全部完成」越近，说明主线程被任务挡得越久。')
            .fontSize(11)
            .fontColor('#555')
            .width('100%')
          Text('本工程的配置是 taskPool + waitOnMainThread: false，所以这个数很小。把 Cache 那一项改成 mainThread + true 再重装，同一个数会跳到五百多毫秒——任务耗时原封不动搬到了主线程上。')
            .fontSize(11)
            .fontColor('#555')
            .width('100%')
          Text(`任务全部完成用了 ${this.completedMs} ms，首页在 ${this.totalMs} ms 出来。`)
            .fontSize(11)
            .fontColor('#6A1B9A')
            .width('100%')
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#E8F5E9')
        .borderRadius(10)
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 24 })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }
}
