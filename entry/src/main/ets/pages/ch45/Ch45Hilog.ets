import { router } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'

// Chapter 45 demo 1 - hilog basics.
// hilog is NOT console.log: it writes into the system log ring buffer, is
// level- and domain-filterable, and is the only thing you can read back after
// a crash via hdc. Two habits worth building from day one:
//   1. Tag your logs with a stable tag (grep-able) and a business domain.
//   2. Treat every user-identifiable value as PRIVATE by default. A format
//      string without %{public} redacts the argument to <private> - if you
//      forget it, the log you need at 2 a.m. is useless.
@Entry
@Component
struct Ch45Hilog {
  @State output: string = '点下面的按钮打日志，再用 hdc 看效果'
  @State level: number = hilog.LogLevel.DEBUG

  // Business domain: 0x0000 is the global domain; real apps slice it up per
  // module (0x0100 network, 0x0200 data ...) so filters stay usable.
  private domain: number = 0x0000
  private tag: string = 'Ch45Hilog'
  private phone: string = '13800138000'

  private emit(level: hilog.LogLevel, name: string, msg: string): void {
    if (!hilog.isLoggable(this.domain, this.tag, level)) {
      this.output = `isLoggable(${name})=false → 当前最低级别 setMinLogLevel 已过滤掉它`
      return
    }
    if (level === hilog.LogLevel.DEBUG) {
      hilog.debug(this.domain, this.tag, msg)
    } else if (level === hilog.LogLevel.INFO) {
      hilog.info(this.domain, this.tag, msg)
    } else if (level === hilog.LogLevel.WARN) {
      hilog.warn(this.domain, this.tag, msg)
    } else {
      hilog.error(this.domain, this.tag, msg)
    }
    this.output = `已打一条 ${name} 日志：hdc shell "hilog | grep ${this.tag}"`
  }

  // The privacy placeholder contrast. Both lines carry the same phone number,
  // but only the %{public}s one survives in the log.
  private privacyContrast(): void {
    hilog.warn(this.domain, this.tag, 'phone=%{private}s (default redacted)', this.phone)
    hilog.warn(this.domain, this.tag, 'phone=%{public}s (plaintext)', this.phone)
    this.output = '两条 WARN 都打出去了，hdc 里对比：一条显示 <private>，一条明文'
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('① hilog：分级打印与隐私占位符')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 12 })

        Text('hilog 写进系统日志环形缓冲区，hdc 能抓、崩溃后能回看——这是它和 console.log 的本质区别。日志默认脱敏，手机号类信息必须显式 %{public} 才会明文输出。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        Row({ space: 8 }) {
          Button('DEBUG')
            .layoutWeight(1)
            .backgroundColor('#546E7A')
            .onClick(() => this.emit(hilog.LogLevel.DEBUG, 'DEBUG', 'demo: a debug detail'))
          Button('INFO')
            .layoutWeight(1)
            .backgroundColor('#317af7')
            .onClick(() => this.emit(hilog.LogLevel.INFO, 'INFO', 'demo: normal business log'))
        }
        .width('100%')

        Row({ space: 8 }) {
          Button('WARN')
            .layoutWeight(1)
            .backgroundColor('#B26A00')
            .onClick(() => this.emit(hilog.LogLevel.WARN, 'WARN', 'demo: recoverable warning'))
          Button('ERROR')
            .layoutWeight(1)
            .backgroundColor('#C5221F')
            .onClick(() => this.emit(hilog.LogLevel.ERROR, 'ERROR', 'demo: failed but handled'))
        }
        .width('100%')

        Button('隐私占位符对比（%{private} vs %{public}）')
          .width('100%')
          .backgroundColor('#6A1B9A')
          .onClick(() => this.privacyContrast())

        Text('全局级别控制（setMinLogLevel）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ top: 8 })

        Row({ space: 8 }) {
          Button('调到 WARN')
            .layoutWeight(1)
            .onClick(() => {
              hilog.setMinLogLevel(hilog.LogLevel.WARN)
              this.level = hilog.LogLevel.WARN
              this.output = 'setMinLogLevel(WARN)：DEBUG/INFO 不再输出，再点 DEBUG 按钮验证'
            })
          Button('恢复 DEBUG')
            .layoutWeight(1)
            .onClick(() => {
              hilog.setMinLogLevel(hilog.LogLevel.DEBUG)
              this.level = hilog.LogLevel.DEBUG
              this.output = 'setMinLogLevel(DEBUG)：全部级别恢复输出'
            })
        }
        .width('100%')

        Text(this.output)
          .fontSize(12)
          .fontColor('#317af7')
          .width('100%')
          .padding(8)
          .backgroundColor('#EEF4FF')
          .borderRadius(6)

        Text('hdc 查看命令：')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ top: 6 })

        Text('hdc shell "hilog | grep Ch45Hilog"')
          .fontSize(12)
          .fontFamily('monospace')
          .width('100%')
          .padding(8)
          .backgroundColor('#F5F7F9')
          .borderRadius(6)
          .copyOption(CopyOptions.InApp)

        Text('isLoggable(domain, tag, level) 是官方推荐预检：先判断再拼字符串，避免高频率日志场景下白白构造日志内容。')
          .fontSize(12)
          .fontColor('#888')
          .width('100%')

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
