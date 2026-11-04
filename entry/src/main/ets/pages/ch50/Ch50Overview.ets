// Chapter 50 §A: the config, on one screen.
//
// AppStartup is a config-driven framework: what runs, in which thread, and who
// waits for whom are all declared in startup_config.json + module.json5. The
// code only fills in init().
@Entry
@Component
struct Ch50OverviewPage {
  private taskRows: string[] = [
    'Ch50TaskConfig  mainThread / 等主线程 / 依赖 无 / 约 60 ms',
    'Ch50TaskCache   taskPool  / 不等      / 依赖 Config / 约 420 ms',
    'Ch50TaskFeed    taskPool  / 不等      / 依赖 Config / 约 380 ms',
    'Ch50TaskReport  taskPool  / 不等      / 手动触发 / 约 300 ms'
  ]

  private configText: string = `// module.json5
{
  "module": {
    "srcEntry": "./ets/ch50stage/Ch50AbilityStage.ets",
    "appStartup": "$profile:startup_config"
  }
}

// resources/base/profile/startup_config.json
{
  "startupTasks": [
    {
      "name": "Ch50TaskConfig",
      "srcEntry": "./ets/startup/Ch50TaskConfig.ets",
      "runOnThread": "mainThread",
      "waitOnMainThread": true
    },
    {
      "name": "Ch50TaskCache",
      "srcEntry": "./ets/startup/Ch50TaskCache.ets",
      "dependencies": ["Ch50TaskConfig"],
      "runOnThread": "taskPool",
      "waitOnMainThread": false
    }
  ],
  "configEntry": "./ets/startup/Ch50StartupConfig.ets"
}`

  private taskText: string = `// one file per task, default export
import { StartupTask, common } from '@kit.AbilityKit'

@Sendable
export default class Ch50TaskCache extends StartupTask {
  constructor() { super() }

  async init(ctx: common.AbilityStageContext): Promise<Object | void> {
    // do the work; whatever you return is cached
    return 'warmed'
  }
}`

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Text('A · 启动框架的四个零件')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 16 })
          .width('92%')

        Text('AppStartup 不要求你把初始化写成一串 await。它要的是三样东西：配置文件、每个任务一个类、一个可选的 configEntry。')
          .fontSize(12)
          .fontColor('#888')
          .width('92%')

        Column({ space: 8 }) {
          ForEach(this.taskRows, (row: string) => {
            Text(row)
              .fontSize(10)
              .fontColor('#333')
              .width('100%')
              .padding({ top: 3, bottom: 3 })
          }, (row: string) => row)
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#E3F2FD')
        .borderRadius(10)
        .alignItems(HorizontalAlign.Start)

        Text('依赖关系：Config 是唯一的前置；Cache 和 Feed 都只依赖 Config，所以它俩同时开跑；Report 不进自动流程。')
          .fontSize(11)
          .fontColor('#317af7')
          .width('92%')

        Text('① module.json5：两个字段就够')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .width('92%')
          .margin({ top: 6 })

        Text(this.configText)
          .fontSize(9)
          .fontColor('#DDD')
          .width('92%')
          .padding(10)
          .backgroundColor('#263238')
          .borderRadius(8)

        Text('② 每个任务一个文件，@Sendable + default export')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .width('92%')
          .margin({ top: 6 })

        Text(this.taskText)
          .fontSize(9)
          .fontColor('#DDD')
          .width('92%')
          .padding(10)
          .backgroundColor('#263238')
          .borderRadius(8)

        Column({ space: 5 }) {
          Text('三个字段决定生死').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#C62828')
          Text('runOnThread：mainThread 还是 taskPool。除了「不拿到就没法画界面」的配置，一律 taskPool。')
            .fontSize(11).fontColor('#555').width('100%')
          Text('waitOnMainThread：只有 true 才真的会挡住首帧。它是 runOnThread: mainThread 的代价开关。')
            .fontSize(11).fontColor('#555').width('100%')
          Text('dependencies：只写真正的前置。写成一条链就把并行写成了串行，省下的时间又还回去了。')
            .fontSize(11).fontColor('#555').width('100%')
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#FFEBEE')
        .borderRadius(10)
        .alignItems(HorizontalAlign.Start)

        Text('一个坑先说在前面：srcEntry 指向的文件里只能有一个 default export 的 StartupTask 子类，任务名和类名要对上。四个任务塞进一个文件是跑不起来的——框架按 name 找类，一个文件只暴露一个。')
          .fontSize(11)
          .fontColor('#E65100')
          .width('92%')
          .padding(10)
          .backgroundColor('#FFF3E0')
          .borderRadius(8)
          .margin({ bottom: 24 })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }
}
