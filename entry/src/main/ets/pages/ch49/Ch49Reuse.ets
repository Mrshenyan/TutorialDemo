// Chapter 49 §B: LazyForEach + @Reusable — the same 300 rows, 8 instances.
//
// LazyForEach only builds what is about to be visible. @Reusable adds a pool on
// top: when a row scrolls out, its component tree is parked instead of
// destroyed, and the next row that comes in borrows it.
//
// So there are three counters, and they tell the whole story:
//   created  — aboutToAppear, real construction
//   reused   — aboutToReuse, an existing instance took new data
//   recycled — aboutToRecycle, an instance went back to the pool
import { router } from '@kit.ArkUI'
import { FeedItem, Ch49Stats, buildFeed } from '../ch49data/Ch49Models'
import { FeedDataSource } from '../ch49data/Ch49DataSource'

@Reusable
@Component
struct Ch49ReuseRow {
  @Prop item: FeedItem = new FeedItem(0, '', '', '#317af7', '#E3F2FD')

  aboutToAppear(): void {
    Ch49Stats.created++
  }

  // aboutToAppear does NOT run again on reuse. This is the only hook where you
  // can hand the new data to an existing instance.
  aboutToReuse(params: Record<string, Object>): void {
    Ch49Stats.reused++
    this.item = params['item'] as FeedItem
  }

  aboutToRecycle(): void {
    Ch49Stats.recycled++
  }

  build() {
    Row({ space: 12 }) {
      Text(`${this.item.index + 1}`)
        .width(34)
        .height(34)
        .textAlign(TextAlign.Center)
        .fontSize(13)
        .fontColor(Color.White)
        .backgroundColor(this.item.hue)
        .borderRadius(17)

      Column({ space: 3 }) {
        Text(this.item.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
        Text(this.item.subtitle)
          .fontSize(11)
          .fontColor('#888')
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('>').fontSize(16).fontColor('#CCC')
    }
    .width('100%')
    .height(64)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.item.tone)
    .borderRadius(8)
  }
}

@Entry
@Component
struct Ch49ReusePage {
  private source: FeedDataSource = new FeedDataSource(buildFeed(300))
  private scroller: Scroller = new Scroller()
  private timer: number = -1

  @State created: number = 0
  @State reused: number = 0
  @State recycled: number = 0
  @State scrollMs: number = 0
  private scrollStart: number = 0

  aboutToAppear(): void {
    Ch49Stats.reset()
    this.timer = setInterval(() => {
      this.created = Ch49Stats.created
      this.reused = Ch49Stats.reused
      this.recycled = Ch49Stats.recycled
    }, 300)
  }

  aboutToDisappear(): void {
    clearInterval(this.timer)
  }

  build() {
    Column({ space: 10 }) {
      Text('B · LazyForEach + @Reusable')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16 })
        .width('92%')

      Text('同样是 300 条。页面 A 里那个 List 每滚过一屏就要新建一屏的组件；这里滚出去的行会被收进复用池，下一行借用它。')
        .fontSize(11)
        .fontColor('#888')
        .width('92%')

      Row({ space: 8 }) {
        Column({ space: 2 }) {
          Text(`${this.created}`).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#2E7D32')
          Text('构造').fontSize(11).fontColor('#888')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 2 }) {
          Text(`${this.reused}`).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#317af7')
          Text('复用').fontSize(11).fontColor('#888')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 2 }) {
          Text(`${this.recycled}`).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#EF6C00')
          Text('回收').fontSize(11).fontColor('#888')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('92%')
      .padding(12)
      .backgroundColor('#E8F5E9')
      .borderRadius(10)

      Row({ space: 8 }) {
        Button('滚到底计时')
          .fontSize(13)
          .layoutWeight(1)
          .onClick(() => {
            this.scrollStart = Date.now()
            this.scroller.scrollToIndex(299)
          })
        Button('回到顶部')
          .fontSize(13)
          .layoutWeight(1)
          .backgroundColor('#607D8B')
          .onClick(() => {
            this.scroller.scrollToIndex(0)
          })
        Button('看坑')
          .fontSize(13)
          .layoutWeight(1)
          .backgroundColor('#C62828')
          .onClick(() => router.pushUrl({ url: 'pages/ch49/Ch49Pitfall' } as router.RouterOptions))
      }
      .width('92%')

      Text(this.scrollMs > 0 ? `滚到底用了 ${this.scrollMs} ms` : '来回滚几次：构造几乎不动，复用一直涨')
        .fontSize(12)
        .fontColor('#2E7D32')
        .width('92%')

      List({ space: 6, scroller: this.scroller }) {
        LazyForEach(this.source, (item: FeedItem) => {
          ListItem() {
            Ch49ReuseRow({ item: item })
              .reuseId('ch49_row')
          }
        }, (item: FeedItem) => `${item.id}`)
      }
      .cachedCount(0)
      .width('92%')
      .layoutWeight(1)
      .padding({ bottom: 16 })
      .onScrollStop(() => {
        if (this.scrollStart > 0) {
          this.scrollMs = Date.now() - this.scrollStart
          this.scrollStart = 0
        }
      })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
