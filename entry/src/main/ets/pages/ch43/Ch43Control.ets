import { router } from '@kit.ArkUI'
import { formBindingData, formInfo, formProvider } from '@kit.FormKit'
import { common } from '@kit.AbilityKit'
import { CH43_STORE_NAME, Ch43CardStore, Ch43Snapshot } from '../../ch43data/Ch43CardStore'

interface BizErr { code: number; message: string }

// The app side of the widget: read/write the same preferences the card reads,
// then push the new data to every published card with formProvider.updateForm.
@Entry
@Component
struct Ch43Control {
  @State done: number = 0
  @State target: number = 5
  @State streak: number = 0
  @State updatedAt: string = '--:--'
  @State cardCount: number = 0
  @State cardLines: string[] = []
  @State log: string = '还没查询桌面卡片'

  aboutToAppear(): void {
    this.reload()
  }

  // Coming back from the card's "打开" button re-enters this page.
  onPageShow(): void {
    this.reload()
  }

  private ctx(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext
  }

  private reload(): void {
    this.apply(Ch43CardStore.load(this.ctx()))
  }

  private apply(snap: Ch43Snapshot): void {
    this.done = snap.done
    this.target = snap.target
    this.streak = snap.streak
    this.updatedAt = snap.updatedAt
  }

  private addOne(): void {
    this.apply(Ch43CardStore.bump(this.ctx()))
    this.pushToCards('app:+1')
  }

  private resetAll(): void {
    this.apply(Ch43CardStore.reset(this.ctx()))
    this.pushToCards('app:reset')
  }

  // formProvider.getPublishedRunningFormInfos() (API 20+) is the supported way
  // to learn which of *your own* cards are alive. No permission needed, and it
  // saves you from having to remember formIds returned by onAddForm.
  private pushToCards(tag: string): void {
    formProvider.getPublishedRunningFormInfos()
      .then((list: formInfo.RunningFormInfo[]) => {
        this.cardCount = list.length
        if (list.length === 0) {
          this.cardLines = []
          this.log = `[${tag}] 桌面还没有卡片，先长按应用图标 → 服务卡片 → 添加上去`
          return
        }
        const binding: formBindingData.FormBindingData =
          formBindingData.createFormBindingData(Ch43CardStore.toBindingData(Ch43CardStore.load(this.ctx())))
        const lines: string[] = []
        for (const c of list) {
          lines.push(`${c.formName} · ${c.formId.substring(0, 10)}… · ${c.dimension} · loc=${c.formLocation}`)
          formProvider.updateForm(c.formId, binding)
            .then(() => {
              this.log = `[${tag}] 已推送 ${list.length} 张卡片`
            })
            .catch((e: BizErr) => {
              const be: BizErr = e as BizErr
              this.log = `[${tag}] updateForm 失败 [${be.code}] ${be.message}`
            })
        }
        this.cardLines = lines
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.log = `[${tag}] 查询已发布卡片失败 [${be.code}] ${be.message}`
      })
  }

  private percent(): number {
    if (this.target <= 0) {
      return 0
    }
    const p: number = Math.round(this.done * 100 / this.target)
    return p > 100 ? 100 : p
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第43篇：服务卡片（主应用侧）')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 12 })

        Text('卡片和 App 读写同一份 preferences。App 改完数据后，调 formProvider.updateForm() 把新数据推给桌面上的卡片。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        // ---------- data ----------
        Row() {
          Column({ space: 4 }) {
            Text('今日进度').fontSize(12).fontColor('#888')
            Text(`${this.done} / ${this.target}`)
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2E7D32')
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Column({ space: 4 }) {
            Text('连续天数').fontSize(12).fontColor('#888')
            Text(`${this.streak} 天`).fontSize(26).fontWeight(FontWeight.Bold)
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#F5F7F9')
        .borderRadius(10)

        Text(`数据源：preferences / ${CH43_STORE_NAME} · 最后写入 ${this.updatedAt}`)
          .fontSize(11)
          .fontColor('#999')
          .width('100%')

        Row() {
          Button('+1 打卡')
            .layoutWeight(1)
            .backgroundColor('#2E7D32')
            .onClick(() => this.addOne())
          Button('重置')
            .layoutWeight(1)
            .backgroundColor('#999')
            .margin({ left: 8 })
            .onClick(() => this.resetAll())
        }
        .width('100%')

        // ---------- card preview ----------
        Text('卡片长这样（2*2 预览）')
          .fontSize(13)
          .fontColor('#888')
          .width('100%')
          .margin({ top: 6 })

        Column() {
          Row() {
            Text('今日打卡').fontSize(14).fontColor('#9AA4B2').fontWeight(FontWeight.Medium)
            Blank()
            Text(`${this.done}/${this.target}`)
              .fontSize(20)
              .fontColor('#3DDC84')
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')

          Row() {
            Row()
              .width(`${this.percent()}%`)
              .height(8)
              .borderRadius(4)
              .backgroundColor('#3DDC84')
          }
          .width('100%')
          .height(8)
          .borderRadius(4)
          .backgroundColor('#2A2F3A')
          .margin({ top: 10 })

          Text(`连续 ${this.streak} 天 · ${this.updatedAt} 更新`)
            .fontSize(12)
            .fontColor('#6E7785')
            .width('100%')
            .margin({ top: 8 })

          Row() {
            Button('+1')
              .fontSize(14)
              .fontColor('#0B0E13')
              .layoutWeight(1)
              .height(34)
              .onClick(() => this.addOne())
            Button('打开')
              .fontSize(14)
              .fontColor('#E6EDF3')
              .backgroundColor('#2A2F3A')
              .layoutWeight(1)
              .height(34)
              .margin({ left: 8 })
              .enabled(false)
          }
          .width('100%')
          .margin({ top: 10 })
        }
        .width(180)
        .height(180)
        .padding(14)
        .borderRadius(16)
        .backgroundColor('#1B1F27')
        .alignItems(HorizontalAlign.Start)

        // ---------- published cards ----------
        Row() {
          Text(`桌面卡片（${this.cardCount}）`).fontSize(13).fontColor('#888')
          Blank()
          Button('查询并刷新')
            .fontSize(12)
            .height(30)
            .backgroundColor('#317af7')
            .onClick(() => this.pushToCards('manual'))
        }
        .width('100%')
        .margin({ top: 6 })

        if (this.cardLines.length === 0) {
          Text('还没有检测到卡片。卡片不能由代码添加到桌面——长按应用图标 → 服务卡片 → 拖动到桌面。')
            .fontSize(12)
            .fontColor('#B26A00')
            .width('100%')
        } else {
          ForEach(this.cardLines, (line: string, idx: number) => {
            Text(line)
              .fontSize(11)
              .fontFamily('monospace')
              .fontColor('#333')
              .width('100%')
              .padding(6)
              .backgroundColor('#F5F7F9')
              .borderRadius(6)
          }, (line: string, idx: number) => `${idx}_${line}`)
        }

        Text(this.log)
          .fontSize(12)
          .fontColor('#317af7')
          .width('100%')
          .padding(8)
          .backgroundColor('#EEF4FF')
          .borderRadius(6)

        Text('提示：卡片刷新是异步的。点完按钮别马上看桌面，回到桌面时卡片会短暂显示旧值再更新——这是系统卡片的刷新策略，不是你代码写错了。')
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
