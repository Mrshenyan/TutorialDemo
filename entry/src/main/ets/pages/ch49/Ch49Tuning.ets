// Chapter 49 §D: the list that changes under you.
//
// Reuse is easy to trust when the data is frozen. The moment you insert or
// delete, every "index" in the list shifts, and the cached component trees are
// still sitting there holding old values.
//
// Two rules decide whether you survive this:
//   1. the key function must return a stable business id, never the position
//   2. the row must read everything it paints from the incoming params
import { FeedItem, Ch49Stats, buildFeed } from '../ch49data/Ch49Models'
import { FeedDataSource } from '../ch49data/Ch49DataSource'

@Reusable
@Component
struct Ch49TunedRow {
  @Prop item: FeedItem = new FeedItem(0, '', '', '#317af7', '#E3F2FD')
  @State instanceId: number = 0

  aboutToAppear(): void {
    Ch49Stats.created++
    this.instanceId = Ch49Stats.nextInstanceId()
  }

  aboutToReuse(params: Record<string, Object>): void {
    Ch49Stats.reused++
    this.item = params['item'] as FeedItem
  }

  build() {
    Row({ space: 8 }) {
      Text(`#${this.instanceId}`).fontSize(10).fontColor('#AAA').width(32)

      Text(`${this.item.id}`)
        .fontSize(11)
        .fontColor(Color.White)
        .width(40)
        .height(20)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.item.hue)
        .borderRadius(10)

      Text(this.item.title)
        .fontSize(13)
        .layoutWeight(1)
        .maxLines(1)

      Text(this.item.liked ? '♥' : '♡')
        .fontSize(15)
        .fontColor(this.item.liked ? '#E53935' : '#CCC')
    }
    .width('100%')
    .height(40)
    .padding({ left: 8, right: 8 })
    .backgroundColor(this.item.tone)
    .borderRadius(6)
  }
}

@Entry
@Component
struct Ch49TuningPage {
  private source: FeedDataSource = new FeedDataSource(buildFeed(250))
  private timer: number = -1

  @State created: number = 0
  @State reused: number = 0
  @State total: number = 250
  @State log: string = '点上面的按钮改数据，看列表有没有错位'

  aboutToAppear(): void {
    Ch49Stats.reset()
    this.timer = setInterval(() => {
      this.created = Ch49Stats.created
      this.reused = Ch49Stats.reused
      this.total = this.source.totalCount()
    }, 300)
  }

  aboutToDisappear(): void {
    clearInterval(this.timer)
  }

  build() {
    Column({ space: 8 }) {
      Text('D · 数据变了，复用还对不对')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 14 })
        .width('92%')

      Text('key 用 id、行内每个值都从 params 拿——这两条做到了，增删才不串。')
        .fontSize(11)
        .fontColor('#888')
        .width('92%')

      Row({ space: 8 }) {
        Column({ space: 2 }) {
          Text(`${this.total}`).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#6A1B9A')
          Text('当前条数').fontSize(10).fontColor('#888')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 2 }) {
          Text(`${this.created}`).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#2E7D32')
          Text('构造').fontSize(10).fontColor('#888')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 2 }) {
          Text(`${this.reused}`).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#317af7')
          Text('复用').fontSize(10).fontColor('#888')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('92%')
      .padding(10)
      .backgroundColor('#F3E5F5')
      .borderRadius(8)

      Row({ space: 6 }) {
        Button('删第 1 条').fontSize(11).layoutWeight(1).backgroundColor('#C62828').onClick(() => {
          this.source.removeAt(0)
          this.log = `删了一条，现在 ${this.source.totalCount()} 条；列表没有整片重建`
        })
        Button('改第 1 条').fontSize(11).layoutWeight(1).backgroundColor('#EF6C00').onClick(() => {
          this.source.renameAt(0, `改过的标题 ${Date.now() % 10000}`)
          this.log = '只通知了这一条变化（onDataChange），其它行没动'
        })
        Button('插到头部').fontSize(11).layoutWeight(1).backgroundColor('#2E7D32').onClick(() => {
          const id: number = Ch49Stats.nextFeedId()
          this.source.insertAt(0, new FeedItem(0, `新插入 #${id}`, '这条是新来的', '#00897B', '#E0F2F1'))
          this.log = '头部插入一条，后面所有行的位置都变了'
        })
      }
      .width('92%')

      Text(this.log)
        .fontSize(11)
        .fontColor('#6A1B9A')
        .width('92%')

      List({ space: 4 }) {
        LazyForEach(this.source, (item: FeedItem) => {
          ListItem() {
            // reuseId is optional here (one row type), but naming the pool
            // explicitly makes the intent obvious in a mixed-type list.
            Ch49TunedRow({ item: item }).reuseId('tuned')
          }
        }, (item: FeedItem) => `row_${item.id}`)
      }
      .cachedCount(3)
      .width('92%')
      .layoutWeight(1)
      .padding({ bottom: 12 })

      Text('注意 key：`row_${item.id}`。如果写成 index，删掉第 1 条之后，第 2 条会用着第 1 条的 key，复用池立刻把内容错位——这是长列表最经典的事故。')
        .fontSize(11)
        .fontColor('#666')
        .width('92%')
        .margin({ bottom: 12 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
