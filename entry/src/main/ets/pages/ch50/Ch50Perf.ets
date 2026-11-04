// Chapter 50 §D: what "the main thread is waiting" actually looks like.
//
// A 100 ms heartbeat runs the whole time. Block the UI thread for 900 ms and the
// heartbeat loses nine beats; move the same work off the thread and it loses none.
// waitOnMainThread: true does exactly the first thing to your launch.
import { hilog } from '@kit.PerformanceAnalysisKit'

@Entry
@Component
struct Ch50PerfPage {
  @State ticks: number = 0
  @State blocking: boolean = false
  @State log: string = '先让心跳跑起来，再点下面两个按钮对比'
  @State lastCost: number = 0
  private timer: number = -1

  aboutToAppear(): void {
    this.timer = setInterval(() => {
      this.ticks++
    }, 100)
  }

  aboutToDisappear(): void {
    clearInterval(this.timer)
  }

  // Occupies the UI thread. Nothing repaints, no timer fires, no tap is handled.
  private blockSync(): void {
    const before: number = this.ticks
    const t0: number = Date.now()
    let acc: number = 0
    while (Date.now() - t0 < 900) {
      acc += Math.sqrt(acc + 1)
    }
    const cost: number = Date.now() - t0
    const expected: number = Math.round(cost / 100)
    const actual: number = this.ticks - before
    this.lastCost = cost
    this.log = `同步占用 ${cost} ms：这期间心跳本该跳 ${expected} 次，实际只跳了 ${actual} 次——差额就是界面完全没响应的时长。`
    hilog.info(0x0000, 'ch50', 'sync block %{public}d ms, heartbeat %{public}d/%{public}d', cost, actual, expected)
  }

  private blockAsync(): void {
    const before: number = this.ticks
    const t0: number = Date.now()
    this.log = '切到定时器里跑，主线程空出来了…'
    setTimeout(() => {
      const cost: number = Date.now() - t0
      const actual: number = this.ticks - before
      this.lastCost = cost
      this.log = `异步 ${cost} ms：同样的活，心跳一次没丢，跳了 ${actual} 次。`
      hilog.info(0x0000, 'ch50', 'async work %{public}d ms, heartbeat %{public}d', cost, actual)
    }, 900)
  }

  build() {
    Column({ space: 12 }) {
      Text('D · 主线程被占住是什么感觉')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16 })
        .width('92%')

      Text('下面这个心跳每 100 ms 跳一次。点「同步占用」，你会在 900 ms 里看到它停住——不是变慢，是彻底不跳。')
        .fontSize(12)
        .fontColor('#888')
        .width('92%')

      Column({ space: 10 }) {
        LoadingProgress()
          .width(44)
          .height(44)
          .color('#317af7')

        Text(`${this.ticks}`)
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .fontColor('#317af7')

        Text('心跳次数（每 100 ms +1）')
          .fontSize(11)
          .fontColor('#888')
      }
      .width('92%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(10)
      .border({ width: 1, color: '#E0E0E0' })

      Row({ space: 8 }) {
        Button('同步占用 900ms')
          .fontSize(13)
          .layoutWeight(1)
          .backgroundColor('#C62828')
          .onClick(() => {
            this.blockSync()
          })
        Button('异步 900ms')
          .fontSize(13)
          .layoutWeight(1)
          .backgroundColor('#2E7D32')
          .onClick(() => {
            this.blockAsync()
          })
        Button('清零')
          .fontSize(13)
          .width(70)
          .backgroundColor('#607D8B')
          .onClick(() => {
            this.ticks = 0
            this.lastCost = 0
            this.log = '重新开始'
          })
      }
      .width('92%')

      Text(this.log)
        .fontSize(12)
        .fontColor('#6A1B9A')
        .width('92%')
        .padding(10)
        .backgroundColor('#F3E5F5')
        .borderRadius(8)

      Column({ space: 6 }) {
        Text('和启动框架的关系').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#C62828')
        Text('startup_config.json 里 runOnThread: mainThread + waitOnMainThread: true，就是把上边那个「同步占用」搬到冷启动里：任务跑多久，首帧就晚多久。')
          .fontSize(11).fontColor('#555').width('100%')
        Text('runOnThread: taskPool + waitOnMainThread: false，等于「异步」：任务照样跑，界面先出来。')
          .fontSize(11).fontColor('#555').width('100%')
        Text('所以启动任务的第一条规矩不是「写得好」，而是「别放主线程」。真正必须在主线程做的，只有那些不拿到结果就没法画首帧的东西——主题、语言、登录态。')
          .fontSize(11).fontColor('#555').width('100%')
      }
      .width('92%')
      .padding(12)
      .backgroundColor('#FFEBEE')
      .borderRadius(10)
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
