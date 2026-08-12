import { router, promptAction } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'

const STORE_NAME: string = 'ch22_observe'

// Chapter 22 §2: subscribe to Preferences changes with on('change').
// Any put()+flush() on the same instance fires the registered callback.
@Entry
@Component
struct PrefsObserve {
  @State count: number = 0
  @State lastKey: string = ''
  @State log: string = '订阅已开启，点击 +1 试试'
  private pref: preferences.Preferences | null = null

  aboutToAppear(): void {
    const context = getContext(this)
    preferences.getPreferences(context, STORE_NAME).then(async (pref: preferences.Preferences) => {
      this.pref = pref
      // Register a change listener; callback receives the changed key as a string.
      pref.on('change', (data: string) => {
        this.lastKey = data
        this.log = `监听到变更，key = ${data}`
        promptAction.showToast({ message: `变更: ${data}` })
      })
      // Load the current persisted value.
      this.count = (await pref.get('count', 0)) as number
    })
  }

  // Remove the listener when the page is destroyed to avoid leaks.
  aboutToDisappear(): void {
    this.pref?.off('change')
    this.pref = null
  }

  async increment(): Promise<void> {
    const pref = this.pref
    if (!pref) {
      return
    }
    this.count += 1
    await pref.put('count', this.count)
    await pref.flush() // flush triggers the 'change' callback on this instance
  }

  async reset(): Promise<void> {
    const pref = this.pref
    if (!pref) {
      return
    }
    this.count = 0
    await pref.put('count', 0)
    await pref.flush()
  }

  build() {
    Column({ space: 16 }) {
      Text('数据变更订阅：on change')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('只要 Preferences 被修改并 flush，注册在实例上的回调就会被触发')
        .fontSize(13)
        .fontColor('#666')
        .margin({ bottom: 8 })

      Text(`${this.count}`)
        .fontSize(48)
        .fontWeight(FontWeight.Bold)

      Text(`最近变更 key: ${this.lastKey}`)
        .fontSize(14)
        .fontColor('#666')

      Button('+1 并保存').width('90%').onClick(() => this.increment())
      Button('重置为 0').width('90%').onClick(() => this.reset())

      Text(this.log).fontSize(13).fontColor('#999')
      Button('返回').width('90%').margin({ top: 8 }).onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
