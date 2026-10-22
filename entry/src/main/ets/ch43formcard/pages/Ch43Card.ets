/**
 * Chapter 43 - the widget UI (ArkTS card).
 *
 * Rules that shape this file:
 *   - No router, no Scroll/Tabs/Swiper/Web/Video, no custom builder chains.
 *     The card only gets the component whitelist the launcher can render.
 *   - The card is a snapshot renderer outside our app's process. Reading data
 *     happens through LocalStorage, which FormExtensionAbility fills via
 *     FormBindingData. Nothing else from the app is reachable.
 *   - Every interaction leaves through postCardAction(); direct state edits or
 *     router.pushUrl() do not work here.
 */

// postCardAction(component, action) takes a plain Object. ArkTS rejects inline
// literals for Object parameters, so the payload shape is declared as classes.
class CardMsgParams {
  msg: string = ''
}

class CardAction {
  action: string = 'message'
  abilityName: string = ''
  params: CardMsgParams = new CardMsgParams()
}

@Entry
@Component
struct Ch43Card {
  // Keys must match the FormBindingData fields built in Ch43CardStore.
  @LocalStorageProp('done') done: number = 0
  @LocalStorageProp('target') target: number = 5
  @LocalStorageProp('streak') streak: number = 0
  @LocalStorageProp('updatedAt') updatedAt: string = '--:--'
  // Injected once by onAddForm: 2 = 2*2, 4 = 4*4.
  @LocalStorageProp('dimension') dimension: number = 2

  private percent(): number {
    if (this.target <= 0) {
      return 0
    }
    const p: number = Math.round(this.done * 100 / this.target)
    return p > 100 ? 100 : p
  }

  private send(action: string, msg: string): void {
    let act: CardAction = new CardAction()
    act.action = action
    act.params.msg = msg
    postCardAction(this, act)
  }

  private openApp(): void {
    let act: CardAction = new CardAction()
    act.action = 'router'
    act.abilityName = 'EntryAbility'
    postCardAction(this, act)
  }

  build() {
    Column() {
      // ---- header ----
      Row() {
        Text('今日打卡')
          .fontSize(14)
          .fontColor('#9AA4B2')
          .fontWeight(FontWeight.Medium)

        Blank()

        Text(`${this.done}/${this.target}`)
          .fontSize(20)
          .fontColor('#3DDC84')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')

      // ---- progress bar (Row inside Row: no Progress component needed) ----
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

      // 4*4 has room for one more hint line; 2*2 would overflow.
      if (this.dimension >= 4) {
        Text('点「+1」直接打卡，数据会立刻写回 App；点右侧按钮打开完整页面。')
          .fontSize(12)
          .fontColor('#9AA4B2')
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 8 })
      }

      Blank()

      // ---- actions ----
      Row() {
        Button('+1')
          .fontSize(14)
          .fontColor('#0B0E13')
          .layoutWeight(1)
          .height(34)
          .onClick(() => this.send('message', 'add'))

        Button('打开')
          .fontSize(14)
          .fontColor('#E6EDF3')
          .backgroundColor('#2A2F3A')
          .layoutWeight(1)
          .height(34)
          .margin({ left: 8 })
          .onClick(() => this.openApp())
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .padding(14)
    .borderRadius(16)
    .backgroundColor('#1B1F27')
    .alignItems(HorizontalAlign.Start)
  }
}
