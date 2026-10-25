import { router } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Ch45LogStore } from '../../ch45data/Ch45LogStore'

// Chapter 45 demo 2 - logging to a private file.
// hilog lives in the system ring buffer: it rolls over, and reading it needs
// hdc. For anything you must keep (a user-reportable trace, a crash trail),
// write your own file in the app sandbox. el2-level files die with the app
// and are not included in cloud backup by default - both properties you
// actually want for logs.
@Entry
@Component
struct Ch45FileLog {
  @State input: string = '点击「写入」生成一条日志'
  @State level: string = 'INFO'
  @State lines: string[] = []
  // NOTE: do NOT name a @State 'size' - it collides with the CustomComponent
  // base property .size(value) and the compiler rejects the override.
  @State fileBytes: number = 0

  private tag: string = 'Ch45FileLog'

  aboutToAppear(): void {
    this.refresh()
  }

  private refresh(): void {
    this.fileBytes = Ch45LogStore.fileSize()
    this.lines = Ch45LogStore.readTail(8)
  }

  private write(): void {
    const ok: boolean = Ch45LogStore.append(this.level, this.tag, this.input)
    hilog.info(0x0000, this.tag, 'file log written ok=%{public}s', ok ? 'true' : 'false')
    this.refresh()
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('② 日志落盘：App 私有目录')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 12 })

        Text('hilog 环形缓冲区会滚动覆盖，且只能 hdc 看。要留下「用户反馈时能捞出来」的日志，就写进 el2 私有目录——随卸载删除、默认不进云备份，这两个特性正是日志需要的。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        TextInput({ text: this.input })
          .width('100%')
          .onChange((v: string) => this.input = v)

        Row({ space: 8 }) {
          Button('DEBUG')
            .layoutWeight(1)
            .backgroundColor(this.level === 'DEBUG' ? '#317af7' : '#B0BEC5')
            .onClick(() => this.level = 'DEBUG')
          Button('INFO')
            .layoutWeight(1)
            .backgroundColor(this.level === 'INFO' ? '#317af7' : '#B0BEC5')
            .onClick(() => this.level = 'INFO')
          Button('WARN')
            .layoutWeight(1)
            .backgroundColor(this.level === 'WARN' ? '#B26A00' : '#B0BEC5')
            .onClick(() => this.level = 'WARN')
          Button('ERROR')
            .layoutWeight(1)
            .backgroundColor(this.level === 'ERROR' ? '#C5221F' : '#B0BEC5')
            .onClick(() => this.level = 'ERROR')
        }
        .width('100%')

        Row({ space: 8 }) {
          Button('写入日志')
            .layoutWeight(1)
            .onClick(() => this.write())
          Button('读回日志')
            .layoutWeight(1)
            .backgroundColor('#00838F')
            .onClick(() => this.refresh())
          Button('清空日志')
            .layoutWeight(1)
            .backgroundColor('#C5221F')
            .onClick(() => {
              Ch45LogStore.clear()
              this.refresh()
            })
        }
        .width('100%')

        Text(`文件：${Ch45LogStore.logPath()}`)
          .fontSize(11)
          .fontFamily('monospace')
          .width('100%')
          .padding(8)
          .backgroundColor('#F5F7F9')
          .borderRadius(6)
          .copyOption(CopyOptions.InApp)

        Text(`文件大小：${this.fileBytes} 字节 · 最近 8 行：`)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .width('100%')

        if (this.lines.length === 0) {
          Text('（还没有日志，点「写入日志」）')
            .fontSize(12)
            .fontColor('#888')
            .width('100%')
        } else {
          ForEach(this.lines, (line: string) => {
            Text(line)
              .fontSize(11)
              .fontFamily('monospace')
              .width('100%')
              .padding(6)
              .backgroundColor('#F5F7F9')
              .borderRadius(4)
          }, (line: string) => line)
        }

        Text('工程要点：写日志用同步 fs 接口（日志不能为了一次磁盘 IO 再等一个 Promise）；多行消息要先压成单行，防止日志注入伪造记录；中文必须用 TextEncoder 编码，直接按 string.length 开 buffer 会写出乱码。')
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
