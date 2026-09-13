import { router } from '@kit.ArkUI';

// Demo ③-c (of ch33): read system environment LIVE.
// AUTHORITATIVE path: UIAbility.onConfigurationUpdate writes the system config into AppStorage
// under app-owned keys (sys.colorMode / sys.fontSizeScale); the page reads them via @StorageProp,
// so toggling dark mode / changing font size in system Settings updates this page in real time.
//
// CONTRAST: Environment's colorMode/fontScale are a READ-ONLY SNAPSHOT. On HarmonyOS 5 they do
// NOT follow live system-setting changes (only languageCode/fontWeightScale follow — verified on
// the Huawei dev forum). We still show them below so you can SEE the difference.
@Entry
@Component
struct Ch33EnvDemo {
  // Live values from onConfigurationUpdate (follow system settings in real time).
  @StorageProp('sys.colorMode') sysColorMode: number = 1;     // 0=dark, 1=light
  @StorageProp('sys.fontSizeScale') fontScale: number = 1.0;

  // Read-only snapshot from Environment (NOT updated when system settings change on NEXT).
  @StorageProp('colorMode') envColorMode: number = 1;
  @StorageProp('fontScale') envFontScale: number = 1.0;

  build() {
    Column({ space: 16 }) {
      Text('实时读取系统环境（onConfigurationUpdate）')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16 })

      Text(`系统深色模式(实时): ${this.sysColorMode === 0 ? '深色 (0)' : '浅色 (1)'}`)
        .fontSize(18)

      Text(`系统字号缩放(实时): ${this.fontScale.toFixed(2)}x`)
        .fontSize(18)

      Text(`Environment 快照 colorMode=${this.envColorMode} / fontScale=${this.envFontScale.toFixed(2)}（不实时跟随）`)
        .fontSize(13)
        .fontColor('#888')
        .width('90%')

      // Visual block that follows the REAL (live) system color mode.
      Column() {
        Text(this.sysColorMode === 0 ? '当前系统：深色' : '当前系统：浅色')
          .fontColor(this.sysColorMode === 0 ? '#eee' : '#222')
      }
      .width('80%')
      .height(110)
      .justifyContent(FlexAlign.Center)
      .borderRadius(12)
      .backgroundColor(this.sysColorMode === 0 ? '#222' : '#EEE')

      Text('去系统设置切换深色 / 调大字号，返回本页：上面两行(实时)会变化，' +
        '而 Environment 快照那行不变 —— 这是 HarmonyOS 5 的已知行为，不是代码错。')
        .fontSize(12)
        .fontColor('#888')
        .width('90%')

      Text('注意：colorMode 由设备决定，App 写不进去。想做"应用内深色开关"，' +
        '要用一个 App 自有的 key（如 app.darkMode），别动 Environment 这个只读量。')
        .fontSize(12)
        .fontColor('#888')
        .width('90%')

      Button('返回')
        .width('80%')
        .margin({ top: 12 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
