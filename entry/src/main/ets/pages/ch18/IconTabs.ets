// Chapter 18 §三-§四: custom tabBar (icon + text + selected color) + Badge.
// Selected state = compare currentIndex with this tab's index.

@Entry
@Component
struct IconTabs {
  @State currentIndex: number = 0
  @State unread: number = 5 // drives the badge on the "发现" tab

  // Custom tab content: emoji icon (use Image($r('app.media.xxx')) in real apps)
  // + text, colored by selected state.
  @Builder
  tabBarBuilder(title: string, icon: string, index: number, showBadge: boolean) {
    Column() {
      Badge({
        count: this.unread,
        position: BadgePosition.RightTop,
        style: { fontSize: 10, badgeSize: 16 }
      }) {
        Text(icon)
          .fontSize(22)
          .fontColor(this.currentIndex === index ? '#007DFF' : '#999999')
      }

      Text(title)
        .fontSize(10)
        .margin({ top: 3 })
        .fontColor(this.currentIndex === index ? '#007DFF' : '#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        Column() { Text('首页内容').fontSize(22) }
        .width('100%').height('100%').justifyContent(FlexAlign.Center)
      }
      .tabBar(this.tabBarBuilder('首页', '🏠', 0, false))

      TabContent() {
        Column() {
          Text('发现内容').fontSize(22)
          Button('清未读').margin({ top: 12 })
            .onClick(() => { this.unread = 0 })
        }
        .width('100%').height('100%').justifyContent(FlexAlign.Center)
      }
      .tabBar(this.tabBarBuilder('发现', '🔍', 1, true))

      TabContent() {
        Column() { Text('我的内容').fontSize(22) }
        .width('100%').height('100%').justifyContent(FlexAlign.Center)
      }
      .tabBar(this.tabBarBuilder('我的', '👤', 2, false))
    }
    .onChange((index: number) => {
      this.currentIndex = index
    })
  }
}
