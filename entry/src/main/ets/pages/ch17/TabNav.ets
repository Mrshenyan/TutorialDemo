// Chapter 17 §六: Tab + Navigation, each Tab gets its own independent stack.
// A single global Navigation would mix Tab stacks and lose pages on switch.

// Global builder: required to be a plain function when shared by multiple
// Navigation components (a member method breaks on the 2nd Navigation -> blank).
@Builder
function PageMap(name: string) {
  if (name === 'PageOne') {
    TabNavPageOne()
  }
}

interface TabParam {
  tabName: string
  time: number
}

@Entry
@Component
struct MainTabs {
  @State currentIndex: number = 0
  private tabsController: TabsController = new TabsController()

  // Each Tab owns an independent NavPathStack.
  @Provide tab1Stack: NavPathStack = new NavPathStack()
  @Provide tab2Stack: NavPathStack = new NavPathStack()
  @Provide tab3Stack: NavPathStack = new NavPathStack()

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {
        Navigation(this.tab1Stack) {
          Column() {
            Text('这是Tab1首页')
              .fontSize(20)
              .margin({ top: 100 })

            Button('从Tab1去详情')
              .onClick(() => {
                let param: TabParam = { tabName: 'Tab1', time: new Date().getTime() }
                this.tab1Stack.pushPathByName('PageOne', param)
              })
          }
          .width('100%')
          .height('100%')
        }
        .mode(NavigationMode.Stack)
        .navDestination(PageMap)
        .hideToolBar(true)
      }
      .tabBar('首页')

      TabContent() {
        Navigation(this.tab2Stack) {
          Column() {
            Text('这是Tab2首页')
              .fontSize(20)
              .margin({ top: 100 })

            Button('从Tab2去详情')
              .onClick(() => {
                let param: TabParam = { tabName: 'Tab2', time: new Date().getTime() }
                this.tab2Stack.pushPathByName('PageOne', param)
              })
          }
          .width('100%')
          .height('100%')
        }
        .mode(NavigationMode.Stack)
        .navDestination(PageMap)
        .hideToolBar(true)
      }
      .tabBar('发现')

      TabContent() {
        Navigation(this.tab3Stack) {
          Column() {
            Text('这是Tab3首页')
              .fontSize(20)
              .margin({ top: 100 })

            Button('从Tab3去详情')
              .onClick(() => {
                let param: TabParam = { tabName: 'Tab3', time: new Date().getTime() }
                this.tab3Stack.pushPathByName('PageOne', param)
              })
          }
          .width('100%')
          .height('100%')
        }
        .mode(NavigationMode.Stack)
        .navDestination(PageMap)
        .hideToolBar(true)
      }
      .tabBar('我的')
    }
    .onChange((index: number) => {
      this.currentIndex = index
    })
  }
}

// Shared detail page (any Tab can push it by the same routeName).
@Component
export struct TabNavPageOne {
  @State tabName: string = ''
  @State time: number = 0
  pathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Column() {
        Text(`来自：${this.tabName}`).fontSize(20)
        Text(`时间戳：${this.time}`).fontSize(16).margin({ top: 8 })

        Button('继续深入')
          .margin({ top: 20 })
          .onClick(() => {
            // Reuse the current page's own stack, do not new a fresh one.
            let param: TabParam = { tabName: this.tabName + '-更深', time: 0 }
            this.pathStack.pushPathByName('PageOne', param)
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .title('详情')
    .onReady((context: NavDestinationContext) => {
      // ★ Grab the real stack this page belongs to (home/mine both correct).
      this.pathStack = context.pathStack
      const params = context.pathInfo?.param as Record<string, Object>
      if (params) {
        this.tabName = (params['tabName'] as string) ?? ''
        this.time = (params['time'] as number) ?? 0
      }
    })
  }
}
