// Chapter 49 §A: how many components ForEach builds depends on its container.
//
// This is the part most tutorials get wrong (I did too, until I counted):
//   ForEach inside a List      -> lazy. The List only attaches what is visible,
//                                 so ~9 components exist, not 300.
//   ForEach inside a Column    -> eager. A Column has to lay out every child,
//                                 so all 300 are built before anything paints.
//
// Same data, same @Component, one container apart. The two counters below are
// the entire argument.
import { FeedItem, Ch49ContainerStats, buildFeed } from '../ch49data/Ch49Models'

@Component
struct Ch49InListRow {
  @Prop item: FeedItem = new FeedItem(0, '', '', '#317af7', '#E3F2FD')

  aboutToAppear(): void {
    Ch49ContainerStats.inList++
  }

  build() {
    Row({ space: 10 }) {
      Text(`${this.item.index + 1}`)
        .width(28).height(28).textAlign(TextAlign.Center)
        .fontSize(12).fontColor(Color.White)
        .backgroundColor(this.item.hue).borderRadius(14)
      Text(this.item.title).fontSize(13).layoutWeight(1).maxLines(1)
    }
    .width('100%').height(44).padding({ left: 10, right: 10 })
    .backgroundColor(this.item.tone).borderRadius(6)
  }
}

@Component
struct Ch49InColumnRow {
  @Prop item: FeedItem = new FeedItem(0, '', '', '#317af7', '#E3F2FD')

  aboutToAppear(): void {
    Ch49ContainerStats.inColumn++
  }

  build() {
    Row({ space: 10 }) {
      Text(`${this.item.index + 1}`)
        .width(28).height(28).textAlign(TextAlign.Center)
        .fontSize(12).fontColor(Color.White)
        .backgroundColor(this.item.hue).borderRadius(14)
      Text(this.item.title).fontSize(13).layoutWeight(1).maxLines(1)
    }
    .width('100%').height(44).padding({ left: 10, right: 10 })
    .backgroundColor(this.item.tone).borderRadius(6)
  }
}

@Entry
@Component
struct Ch49BaselinePage {
  private items: FeedItem[] = buildFeed(300)
  private timer: number = -1

  @State inList: number = 0
  @State inColumn: number = 0

  aboutToAppear(): void {
    Ch49ContainerStats.reset()
    this.timer = setInterval(() => {
      this.inList = Ch49ContainerStats.inList
      this.inColumn = Ch49ContainerStats.inColumn
    }, 300)
  }

  aboutToDisappear(): void {
    clearInterval(this.timer)
  }

  build() {
    Column({ space: 8 }) {
      Text('A · 同一个 ForEach，两种容器')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 14 })
        .width('92%')

      Text('300 条数据、同一个组件。上面放进 List，下面放进 Column。看两边各建了几个。')
        .fontSize(11)
        .fontColor('#888')
        .width('92%')

      Row({ space: 8 }) {
        Column({ space: 2 }) {
          Text(`${this.inList}`).fontSize(28).fontWeight(FontWeight.Bold).fontColor('#2E7D32')
          Text('List 里构造').fontSize(10).fontColor('#888')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 2 }) {
          Text(`${this.inColumn}`).fontSize(28).fontWeight(FontWeight.Bold).fontColor('#C62828')
          Text('Column 里构造').fontSize(10).fontColor('#888')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('92%')
      .padding(10)
      .backgroundColor('#FAFAFA')
      .borderRadius(10)
      .border({ width: 1, color: '#EEE' })

      Text('① List + ForEach（懒：只建看得见的）')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2E7D32')
        .width('92%')

      List({ space: 4 }) {
        ForEach(this.items, (item: FeedItem) => {
          ListItem() {
            Ch49InListRow({ item: item })
          }
        }, (item: FeedItem) => `l_${item.id}`)
      }
      .cachedCount(2)
      .width('92%')
      .height(210)
      .backgroundColor('#F7FBF7')
      .borderRadius(8)

      Text('② Scroll + Column + ForEach（急：全部建完）')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#C62828')
        .width('92%')
        .margin({ top: 4 })

      Scroll() {
        Column({ space: 4 }) {
          ForEach(this.items, (item: FeedItem) => {
            Ch49InColumnRow({ item: item })
          }, (item: FeedItem) => `c_${item.id}`)
        }
        .width('100%')
        .padding(4)
      }
      .width('92%')
      .height(180)
      .backgroundColor('#FDF7F7')
      .borderRadius(8)
      .scrollBar(BarState.Off)

      Text('List 帮了 ForEach 一个大忙：它只挂载可见区域。一旦换成 Column，ForEach 就变成「先全建完再显示」——300 条数据就是 300 个组件，10000 条就是 10000 个。')
        .fontSize(11)
        .fontColor('#666')
        .width('92%')
        .margin({ top: 2, bottom: 12 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
