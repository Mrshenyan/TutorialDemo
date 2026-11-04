// Chapter 50 §C: manual mode — pay for it only when someone opens it.
//
// Ch50TaskReport is declared with excludeFromAutoStart: true, so it never runs
// during launch. The first click here is the only time those 300 ms are spent.
import { startupManager } from '@kit.AbilityKit'

@Entry
@Component
struct Ch50ManualPage {
  @State initialized: boolean = false
  @State cost: number = 0
  @State log: string = '还没初始化——它一次都没在启动时跑过'
  @State running: boolean = false

  aboutToAppear(): void {
    this.initialized = startupManager.isStartupTaskInitialized('Ch50TaskReport')
  }

  private async runManual(): Promise<void> {
    if (startupManager.isStartupTaskInitialized('Ch50TaskReport')) {
      this.log = '已经初始化过了。startupManager 不会重复执行同一个任务。'
      this.initialized = true
      return
    }
    this.running = true
    const t0: number = Date.now()
    try {
      await startupManager.run(['Ch50TaskReport'])
      this.cost = Date.now() - t0
      this.initialized = true
      this.log = `初始化完成，实际等了 ${this.cost} ms`
    } catch (e) {
      this.log = `失败：${JSON.stringify(e)}`
    }
    this.running = false
  }

  build() {
    Column({ space: 12 }) {
      Text('C · 该延迟的，就别放在启动里')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16 })
        .width('92%')

      Text('报表模块只有用户点进「统计」才用得上，配了 excludeFromAutoStart: true。它不占启动时间，第一次真正需要时再跑。')
        .fontSize(12)
        .fontColor('#888')
        .width('92%')

      Column({ space: 8 }) {
        Row({ space: 6 }) {
          Text(this.initialized ? '●' : '○')
            .fontSize(12)
            .fontColor(this.initialized ? '#2E7D32' : '#BBB')
          Text(this.initialized ? 'Ch50TaskReport 已初始化' : 'Ch50TaskReport 未初始化')
            .fontSize(14)
            .fontColor(this.initialized ? '#2E7D32' : '#666')
        }

        Text(this.log)
          .fontSize(11)
          .fontColor('#6A1B9A')
          .width('100%')
      }
      .width('92%')
      .padding(12)
      .backgroundColor('#F3E5F5')
      .borderRadius(10)
      .alignItems(HorizontalAlign.Start)

      Button(this.running ? '跑着呢…' : '现在初始化报表模块')
        .width('92%')
        .enabled(!this.running)
        .backgroundColor('#6A1B9A')
        .onClick(() => {
          this.runManual()
        })

      Button('再点一次（验证不会重复跑）')
        .width('92%')
        .backgroundColor('#607D8B')
        .onClick(() => {
          this.runManual()
        })

      Column({ space: 6 }) {
        Text('两种模式怎么选').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#317af7')
        Text('自动模式：首屏就要用的东西——配置、登录态、主题、首屏数据。')
          .fontSize(11).fontColor('#555').width('100%')
        Text('手动模式：二三级页面才用得到的东西——报表、地图、编辑器、大字典。')
          .fontSize(11).fontColor('#555').width('100%')
        Text('判断标准只有一句话：这次冷启动的用户，会不会在 1 秒内用到它。不会，就挪出去。')
          .fontSize(11).fontColor('#555').width('100%')
      }
      .width('92%')
      .padding(12)
      .backgroundColor('#E3F2FD')
      .borderRadius(10)
      .alignItems(HorizontalAlign.Start)

      Text('注意：HSP / HAR 里的启动任务只支持手动模式，自动调度只发生在 entry 模块。跨模块依赖要用 dependencies 显式声明，框架会顺着依赖链把 HSP 里的任务一起拉起来。')
        .fontSize(11)
        .fontColor('#888')
        .width('92%')
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
