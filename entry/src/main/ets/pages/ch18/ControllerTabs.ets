// Chapter 18 §五: switch tabs programmatically with TabsController.
// The same controller instance must be passed to both Tabs({ controller })
// and used for changeIndex.

@Entry
@Component
struct ControllerTabs {
  @State currentIndex: number = 0
  // ★ Controller must be the SAME instance as the one given to Tabs.
  private tabsController: TabsController = new TabsController()

  build() {
    Column() {
      Row() {
        Button('去发现').margin(8)
          .onClick(() => {
            this.tabsController.changeIndex(1) // switch to 2nd tab (index=1)
          })
        Button('回首页').margin(8)
          .onClick(() => {
            this.tabsController.changeIndex(0)
          })
      }

      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        TabContent() {
          Column() { Text('首页') }.justifyContent(FlexAlign.Center).width('100%').height('100%')
        }
        .tabBar('首页')

        TabContent() {
          Column() { Text('发现') }.justifyContent(FlexAlign.Center).width('100%').height('100%')
        }
        .tabBar('发现')
      }
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
