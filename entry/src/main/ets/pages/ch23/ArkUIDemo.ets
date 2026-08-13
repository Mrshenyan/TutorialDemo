import { router } from '@kit.ArkUI'

// ArkUI template demo: deep observation with @ObjectLink so that changing one item
// only rebuilds the card that owns it. Record with the Profiler "ArkUI" template
// (ArkUI State lane / Delivery Chain) to see redundant vs. precise refresh.
// Anti-pattern (material §6.6): passing a whole object via @Prop copies it and makes
// every child re-render when any field changes.
// NOTE: build() must contain exactly ONE root container component; do not put plain
// statements (e.g. side-effect counters) as siblings of the UI tree.

@Observed
class Ch23ArkItem {
  id: number = 0
  title: string = ''
  likeCount: number = 0
  constructor(id: number, title: string) {
    this.id = id
    this.title = title
  }
}

@Observed
class Ch23ArkModel {
  items: Ch23ArkItem[] = []
}

// GOOD: @ObjectLink deep-observes one item; only this card rebuilds when its item changes.
@Component
struct Ch23ArkCard {
  @ObjectLink item: Ch23ArkItem
  build() {
    Row({ space: 8 }) {
      Text(`${this.item.title}  赞:${this.item.likeCount}`)
        .fontSize(15)
      Button('+1').onClick(() => {
        this.item.likeCount += 1
      })
    }
    .padding(8)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }
}

@Entry
@Component
struct Ch23ArkUI {
  @State model: Ch23ArkModel = new Ch23ArkModel()

  aboutToAppear(): void {
    this.model = new Ch23ArkModel()
    this.model.items.push(new Ch23ArkItem(0, '文章A'))
    this.model.items.push(new Ch23ArkItem(1, '文章B'))
    this.model.items.push(new Ch23ArkItem(2, '文章C'))
  }

  build() {
    Column({ space: 12 }) {
      Text('ArkUI · 组件耗时与状态刷新')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24 })

      Text('用 Profiler ArkUI State 泳道看冗余刷新；@ObjectLink 只刷新变化的卡片')
        .fontSize(13)
        .fontColor('#666')
        .margin({ bottom: 8 })

      ForEach(this.model.items, (it: Ch23ArkItem) => {
        Ch23ArkCard({ item: it })
      }, (it: Ch23ArkItem) => it.id.toString())

      Button('只给文章A +1（仅卡片A重渲染）').width('90%')
        .onClick(() => {
          this.model.items[0].likeCount += 1
        })

      Text('对比：若用 @Prop 传整个对象，点任意 +1 都会让三张卡片一起重渲染')
        .fontSize(12)
        .fontColor('#999')

      Button('返回').width('90%').margin({ top: 8 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
