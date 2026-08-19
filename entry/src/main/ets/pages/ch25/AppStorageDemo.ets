import { router } from '@kit.ArkUI';

// Chapter 25 §2: AppStorage is a process-wide global singleton.
// Any component (even non-parent-child) bound to the same key stays in sync.
// This is what @State / @Link / @Provide cannot do across unrelated components.

@Entry
@Component
struct AppStorageDemo {
  // Two-way link to the global singleton. Local change -> writes to AppStorage,
  // and changes elsewhere in the app -> flow back here automatically.
  @StorageLink('app.theme') themeColor: string = 'blue';
  @StorageLink('app.user') userName: string = '游客';

  aboutToAppear(): void {
    // MUST exist before the first @StorageLink read, else value is undefined.
    AppStorage.SetOrCreate('app.theme', 'blue');
    AppStorage.SetOrCreate('app.user', '游客');
    AppStorage.SetOrCreate('app.appName', '跟着cc学鸿蒙');
  }

  build() {
    Column({ space: 16 }) {
      Text('AppStorage：全局状态')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('当前登录：' + this.userName)
        .fontSize(16)
        .fontColor(this.themeColor)

      Row({ space: 12 }) {
        Button('切换主题色').onClick(() => {
          this.themeColor = this.themeColor === 'blue' ? 'red' : 'blue';
        })
        Button('登录 / 退出').onClick(() => {
          this.userName = this.userName === '游客' ? 'cc' : '游客';
        })
      }

      // A child component (NOT a parent) also reads the same global key.
      ThemeCard()

      // One-way demo: @StorageProp only reads, local writes don't sync back.
      ReadOnlyCard()

      Text('命令式 API：AppStorage.Get / Set / Delete')
        .fontSize(14)
        .margin({ top: 8 })

      Row({ space: 12 }) {
        Button('API 改主题色').onClick(() => {
          AppStorage.Set('app.theme', 'green');
        })
        Button('重置登录态').onClick(() => {
          // A key with live subscribers (this @StorageLink) CANNOT be deleted;
          // Delete returns false. Use Set to reset to the default "guest" instead.
          AppStorage.Set('app.user', '游客');
        })
      }

      Button('返回').width('80%').margin({ top: 16 }).onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}

// Child component: still synced to 'app.theme' without any @Link passing.
@Component
struct ThemeCard {
  @StorageLink('app.theme') themeColor: string = 'blue';

  build() {
    Column({ space: 8 }) {
      Text('子组件读到的主题色：' + this.themeColor)
        .fontSize(15)
        .fontColor(this.themeColor)
      Text('（改上面按钮，这里同步变化 —— 证明是全局单例）')
        .fontSize(12)
        .fontColor('#999')
    }
    .width('90%')
    .padding(12)
    .border({ width: 1, color: this.themeColor })
    .borderRadius(8)
  }
}

// One-way demo: @StorageProp reads from AppStorage but local change does NOT sync back.
@Component
struct ReadOnlyCard {
  @StorageProp('app.appName') appName: string = '跟着cc学鸿蒙';

  build() {
    Column({ space: 8 }) {
      Text('只读配置（@StorageProp）：' + this.appName)
        .fontSize(15)
      Button('本地改（不会回写全局）').onClick(() => {
        // Only changes the local copy; AppStorage keeps the old value.
        this.appName = '本地临时名';
      })
    }
    .width('90%')
    .padding(12)
    .border({ width: 1, color: '#999' })
    .borderRadius(8)
  }
}
