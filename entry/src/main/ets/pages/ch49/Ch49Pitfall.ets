// Chapter 49 §C: the trap that bites everyone once.
//
// A reused component is NOT a fresh component. @State initialisers run once,
// at construction. When the instance is borrowed for another row, whatever the
// previous row left behind is still there.
//
// Both lists below hold the same 120 rows with a like button. The only
// difference is one line in aboutToReuse. Like a few rows in the top list, jump
// to row 60, jump back — the hearts have moved to other rows.
import { FeedItem, Ch49Stats, buildFeed } from '../ch49data/Ch49Models'
import { FeedDataSource } from '../ch49data/Ch49DataSource'

// ---- WRONG: liked survives across owners ----
@Reusable
@Component
struct Ch49LeakyRow {
  @Prop item: FeedItem = new FeedItem(0, '', '', '#317af7', '#E3F2FD')
  @State liked: boolean = false
  @State instanceId: number = 0

  aboutToAppear(): void {
    this.instanceId = Ch49Stats.nextInstanceId()
  }

  aboutToReuse(params: Record<string, Object>): void {
    this.item = params['item'] as FeedItem
    // liked is intentionally left alone: this is the bug.
  }

  build() {
    Row({ space: 8 }) {
      Text(`#${this.instanceId}`)
        .fontSize(10)
        .fontColor('#999')
        .width(32)

      Text(`${this.item.index + 1}`)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .maxLines(1)

      Text(this.liked ? '♥' : '♡')
        .fontSize(18)
        .fontColor(this.liked ? '#E53935' : '#BBB')
        .padding({ left: 10, right: 10 })
        .onClick(() => {
          this.liked = !this.liked
        })
    }
    .width('100%')
    .height(44)
    .padding({ left: 8, right: 8 })
    .backgroundColor(this.liked ? '#FFEBEE' : '#F5F5F5')
    .borderRadius(6)
  }
}

// ---- RIGHT: state is restored from the data source on reuse ----
@Reusable
@Component
struct Ch49CleanRow {
  @Prop item: FeedItem = new FeedItem(0, '', '', '#317af7', '#E3F2FD')
  @State liked: boolean = false
  @State instanceId: number = 0
  // Plain member (not a state var) used to push the change back to the source.
  onToggle: (id: number, liked: boolean) => void = () => {
  }

  aboutToAppear(): void {
    this.instanceId = Ch49Stats.nextInstanceId()
    this.liked = this.item.liked
  }

  aboutToReuse(params: Record<string, Object>): void {
    const next: FeedItem = params['item'] as FeedItem
    this.item = next
    // The one line that fixes it.
    this.liked = next.liked
  }

  build() {
    Row({ space: 8 }) {
      Text(`#${this.instanceId}`)
        .fontSize(10)
        .fontColor('#999')
        .width(32)

      Text(`${this.item.index + 1}`)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .maxLines(1)

      Text(this.liked ? '♥' : '♡')
        .fontSize(18)
        .fontColor(this.liked ? '#E53935' : '#BBB')
        .padding({ left: 10, right: 10 })
        .onClick(() => {
          this.liked = !this.liked
          this.onToggle(this.item.id, this.liked)
        })
    }
    .width('100%')
    .height(44)
    .padding({ left: 8, right: 8 })
    .backgroundColor(this.liked ? '#FFEBEE' : '#F5F5F5')
    .borderRadius(6)
  }
}

@Entry
@Component
struct Ch49PitfallPage {
  private leakySource: FeedDataSource = new FeedDataSource(buildFeed(400))
  private cleanSource: FeedDataSource = new FeedDataSource(buildFeed(400))
  private scrollerA: Scroller = new Scroller()
  private scrollerB: Scroller = new Scroller()

  private onToggle = (id: number, liked: boolean): void => {
    this.cleanSource.setLikedById(id, liked)
  }

  build() {
    Column({ space: 6 }) {
      Text('C · 复用最坑的地方')
        .fontSize(19)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 12 })
        .width('92%')

      Text('两条列表数据一样、代码几乎一样，区别只在 aboutToReuse 里有没有恢复 liked。在上面的列表里点几个心，然后跳到第 300 条再跳回来——400 条数据足够把旧实例挤出缓存。')
        .fontSize(10)
        .fontColor('#888')
        .width('92%')

      Row({ space: 6 }) {
        Text('✗').fontSize(12).fontColor('#C62828')
        Text('忘了恢复：心跟着组件跑').fontSize(11).fontColor('#C62828')
        Blank()
        Button('跳第300条')
          .fontSize(10)
          .height(28)
          .padding({ left: 10, right: 10 })
          .onClick(() => {
            this.scrollerA.scrollToIndex(299)
            this.scrollerB.scrollToIndex(299)
          })
        Button('回顶部')
          .fontSize(10)
          .height(28)
          .padding({ left: 10, right: 10 })
          .backgroundColor('#607D8B')
          .onClick(() => {
            this.scrollerA.scrollToIndex(0)
            this.scrollerB.scrollToIndex(0)
          })
      }
      .width('92%')

      List({ space: 4, scroller: this.scrollerA }) {
        LazyForEach(this.leakySource, (item: FeedItem) => {
          ListItem() {
            Ch49LeakyRow({ item: item }).reuseId('leaky')
          }
        }, (item: FeedItem) => `leaky_${item.id}`)
      }
      .cachedCount(0)
      .width('92%')
      .height(210)
      .backgroundColor('#FFF5F5')
      .borderRadius(8)

      Row({ space: 6 }) {
        Text('✓').fontSize(12).fontColor('#2E7D32')
        Text('从数据源恢复：回来还是那几个赞').fontSize(11).fontColor('#2E7D32')
      }
      .width('92%')
      .margin({ top: 2 })

      List({ space: 4, scroller: this.scrollerB }) {
        LazyForEach(this.cleanSource, (item: FeedItem) => {
          ListItem() {
            Ch49CleanRow({ item: item, onToggle: this.onToggle }).reuseId('clean')
          }
        }, (item: FeedItem) => `clean_${item.id}`)
      }
      .cachedCount(0)
      .width('92%')
      .height(210)
      .backgroundColor('#F5FFF5')
      .borderRadius(8)

      Text('左边那列 #1 #2 #3 是组件实例号。滚的时候盯住它：数据号一直在变，实例号来回就那几个——屏幕上这些行就是这几个盒子轮流用的。')
        .fontSize(10)
        .fontColor('#666')
        .width('92%')
        .margin({ top: 4, bottom: 8 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
