import { router } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'

const STORE_NAME: string = 'ch22_store' // preferences file name (one file = one Preferences instance)

// Chapter 22 §1: basic read / write / delete / clear with Preferences.
// Preferences = lightweight KV store: in-memory cache + persisted file.
@Entry
@Component
struct PrefsBasic {
  @State nickname: string = ''
  @State age: number = 0
  @State darkMode: boolean = false
  @State log: string = '点击按钮开始操作'
  private pref: preferences.Preferences | null = null

  aboutToAppear(): void {
    // getPreferences returns a Promise<Preferences>; resolve once, then load saved values.
    const context = getContext(this)
    preferences.getPreferences(context, STORE_NAME).then((pref: preferences.Preferences) => {
      this.pref = pref
      this.loadAll()
    })
  }

  // Load all persisted values into @State so the UI reflects the disk state.
  async loadAll(): Promise<void> {
    const pref = this.pref
    if (!pref) {
      return
    }
    this.nickname = (await pref.get('nickname', '')) as string
    this.age = (await pref.get('age', 0)) as number
    this.darkMode = (await pref.get('darkMode', false)) as boolean
    this.log = '已加载本地数据'
  }

  // put() writes to memory; flush() persists to the file (required to survive app restart).
  async saveAll(): Promise<void> {
    const pref = this.pref
    if (!pref) {
      return
    }
    await pref.put('nickname', this.nickname)
    await pref.put('age', this.age)
    await pref.put('darkMode', this.darkMode)
    await pref.flush()
    this.log = '已保存（已落盘）'
  }

  async deleteNickname(): Promise<void> {
    const pref = this.pref
    if (!pref) {
      return
    }
    await pref.delete('nickname')
    await pref.flush()
    this.nickname = ''
    this.log = '已删除 nickname'
  }

  async checkExists(): Promise<void> {
    const pref = this.pref
    if (!pref) {
      return
    }
    const exists: boolean = await pref.has('nickname')
    this.log = exists ? 'nickname 存在' : 'nickname 不存在'
  }

  async clearAll(): Promise<void> {
    const pref = this.pref
    if (!pref) {
      return
    }
    await pref.clear()
    await pref.flush()
    this.nickname = ''
    this.age = 0
    this.darkMode = false
    this.log = '已清空所有键'
  }

  build() {
    Column({ space: 12 }) {
      Text('基础读写：增删改查')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('Preferences = 轻量级 KV 存储：进程内缓存 + 落盘文件')
        .fontSize(13)
        .fontColor('#666')
        .margin({ bottom: 8 })

      // nickname (string)
      TextInput({ text: this.nickname, placeholder: '输入昵称' })
        .width('90%')
        .onChange((v: string) => {
          this.nickname = v
        })

      // age (number) stepper
      Row({ space: 12 }) {
        Button('-').onClick(() => {
          this.age = this.age > 0 ? this.age - 1 : 0
        })
        Text(`年龄: ${this.age}`).fontSize(18)
        Button('+').onClick(() => {
          this.age += 1
        })
      }

      // darkMode (boolean) toggle
      Row({ space: 12 }) {
        Text('夜间模式').fontSize(16)
        Toggle({ isOn: this.darkMode, type: ToggleType.Switch })
          .onChange((v: boolean) => {
            this.darkMode = v
          })
      }

      Button('保存全部').width('90%').onClick(() => this.saveAll())
      Button('读取全部').width('90%').onClick(() => this.loadAll())
      Button('删除 nickname').width('90%').onClick(() => this.deleteNickname())
      Button('检查 nickname 是否存在').width('90%').onClick(() => this.checkExists())
      Button('清空所有').width('90%').onClick(() => this.clearAll())

      Text(this.log).fontSize(14).fontColor('#999').margin({ top: 8 })
      Button('返回').width('90%').margin({ top: 8 }).onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
