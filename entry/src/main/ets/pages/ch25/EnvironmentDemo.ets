import { router } from '@kit.ArkUI';

// Chapter 25 §4: Environment exposes READ-ONLY system state.
// Common keys: 'languageCode', 'colorMode', 'fontSizeScale', 'fontWeightScale', 'deviceType'.
// App side can only READ them. Environment.EnvProp is for the initial link only.
//
// IMPORTANT: once linked, 'colorMode' is bound to the DEVICE and is read-only.
// Writing to it (via EnvProp again OR AppStorage.Set) is ignored — the device value wins.
// So "simulate dark/light" must use a SEPARATE app-owned key (app.darkMode),
// not the read-only Environment colorMode.
//
// colorMode mapping (verified from this SDK's ConfigurationConstant.ColorMode):
//   0 = dark (深色), 1 = light (浅色). Flip if your device shows the opposite.

@Entry
@Component
struct EnvironmentDemo {
  // --- read-only system state (linked via EnvProp in aboutToAppear) ---
  @StorageProp('colorMode') sysColorMode: number = 1;
  @StorageProp('fontSizeScale') fontSizeScale: number = 1.0;

  // --- app-owned, WRITABLE theme switch (NOT environment-linked) ---
  @StorageProp('app.darkMode') darkMode: boolean = false;

  aboutToAppear(): void {
    // Link system environment into AppStorage so @StorageProp can read it.
    Environment.EnvProp('colorMode', 1); // default light
    Environment.EnvProp('fontSizeScale', 1.0);
    // Create the app-owned switch key (writable by AppStorage.Set).
    AppStorage.SetOrCreate('app.darkMode', false);
  }

  build() {
    Column({ space: 16 }) {
      Text('Environment：设备环境（只读）')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      // Part A: real system values — read-only, follow the device.
      Text('系统深浅色（跟随设备，只读）：' + (this.sysColorMode === 0 ? '深色（暗）' : '浅色（亮）'))
        .fontSize(16)
      Text('系统字体缩放（只读）：' + this.fontSizeScale)
        .fontSize(16)

      // Part B: app-owned theme preview — driven by a WRITABLE AppStorage key.
      Column({ space: 8 }) {
        Text(this.darkMode ? '当前预览：深色' : '当前预览：浅色')
          .fontColor(this.darkMode ? '#ffffff' : '#000000')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text('这是可手动切换的主题预览（写入 AppStorage 自有 key，非 Environment）')
          .fontColor(this.darkMode ? '#ffffff' : '#000000')
          .fontSize(12)
      }
      .width('90%')
      .padding(16)
      .backgroundColor(this.darkMode ? '#1a1a1a' : '#f2f2f2')

      // Simulate dark/light by writing the writable key, NOT the read-only colorMode.
      Row({ space: 12 }) {
        Button('模拟深色').onClick(() => {
          AppStorage.Set<boolean>('app.darkMode', true);
        })
        Button('模拟浅色').onClick(() => {
          AppStorage.Set<boolean>('app.darkMode', false);
        })
      }

      Text('（Environment 的真实 colorMode 应用改不了；去系统设置切换后回本页，上方系统值会自动跟随）')
        .fontSize(12)
        .fontColor('#999')

      Button('返回').width('80%').margin({ top: 16 }).onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
