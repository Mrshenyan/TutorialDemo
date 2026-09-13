import { router } from '@kit.ArkUI';

// Demo ③-b (of ch33): PersistentStorage binds an AppStorage key to disk.
// After PersistProp, any @StorageLink writing to that key is auto-saved,
// and survives app kill + restart.
const PERSIST_KEY: string = 'ch33_theme';

PersistentStorage.persistProp(PERSIST_KEY, 'blue');
@Entry
@Component
struct Ch33PersistDemo {
  // @StorageLink reads/writes the persisted key. Default 'blue' only applies first launch.
  @StorageLink(PERSIST_KEY) theme: string = 'blue';


  build() {
    Column({ space: 16 }) {
      Text('PersistentStorage 持久化')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16 })

      Text(`当前主题色: ${this.theme}`)
        .fontSize(18)

      Row({ space: 12 }) {
        Button('选蓝色')
          .backgroundColor('#1565C0')
          .onClick(() => { this.theme = 'blue'; })
        Button('选绿色')
          .backgroundColor('#2E7D32')
          .onClick(() => { this.theme = 'green'; })
      }

      // A preview box whose color follows the persisted theme.
      Column() {
        Text('预览卡片（颜色来自持久化主题）')
          .fontColor('#fff')
      }
      .width('80%')
      .height(120)
      .justifyContent(FlexAlign.Center)
      .borderRadius(12)
      .backgroundColor(this.theme === 'green' ? '#2E7D32' : '#1565C0')

      Text('操作：切个颜色 → 杀掉 App 重开 → 颜色还在，就说明落盘成功了。')
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
