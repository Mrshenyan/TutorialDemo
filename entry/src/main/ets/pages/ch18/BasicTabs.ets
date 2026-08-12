// Chapter 18 §二: minimal bottom Tabs.
// Rules: Tabs children must be TabContent; each TabContent needs a .tabBar.

@Entry
@Component
struct BasicTabs {
  @State currentIndex: number = 0

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        Column() {
          Text('这是「首页」页面').fontSize(22)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
      .tabBar('首页')

      TabContent() {
        Column() {
          Text('这是「发现」页面').fontSize(22)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
      .tabBar('发现')

      TabContent() {
        Column() {
          Text('这是「我的」页面').fontSize(22)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
      .tabBar('我的')
    }
    .onChange((index: number) => {
      this.currentIndex = index
      console.log('切到了第 ' + index + ' 个 Tab')
    })
  }
}
