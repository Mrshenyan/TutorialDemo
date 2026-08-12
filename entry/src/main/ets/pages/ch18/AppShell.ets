// Chapter 18 §六: Tabs + Navigation, each Tab owns an independent stack.
// Switching Tab keeps the other Tab's detail page alive.

// Global builder (plain function) for multiple Navigations to share.
@Builder
function PageMap(name: string) {
  if (name === 'Detail') {
    DetailPage()
  }
}

interface FromParam {
  from: string
}

@Entry
@Component
struct AppShell {
  @State currentIndex: number = 0
  private tabsController: TabsController = new TabsController()

  // Each Tab a separate stack.
  @Provide('homeStack') homeStack: NavPathStack = new NavPathStack()
  @Provide('mineStack') mineStack: NavPathStack = new NavPathStack()

  @Builder
  tabBarBuilder(title: string, icon: string, index: number) {
    Column() {
      Text(icon).fontSize(22)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#999999')
      Text(title).fontSize(10).margin({ top: 3 })
        .fontColor(this.currentIndex === index ? '#007DFF' : '#999999')
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      // —— Tab1: home (internal Navigation jump to detail) ——
      TabContent() {
        Navigation(this.homeStack) {
          Column() {
            Text('首页').fontSize(22).margin({ top: 80 })
            Button('看详情').margin({ top: 16 })
              .onClick(() => {
                let param: FromParam = { from: '首页' }
                this.homeStack.pushPathByName('Detail', param)
              })
          }
          .width('100%').height('100%')
        }
        .mode(NavigationMode.Stack)
        .navDestination(PageMap)
        .title('首页')
        .hideToolBar(true)
      }
      .tabBar(this.tabBarBuilder('首页', '🏠', 0))

      // —— Tab2: mine (independent stack, no cross-contamination) ——
      TabContent() {
        Navigation(this.mineStack) {
          Column() {
            Text('我的').fontSize(22).margin({ top: 80 })
            Button('看详情').margin({ top: 16 })
              .onClick(() => {
                let param: FromParam = { from: '我的' }
                this.mineStack.pushPathByName('Detail', param)
              })
          }
          .width('100%').height('100%')
        }
        .mode(NavigationMode.Stack)
        .navDestination(PageMap)
        .title('我的')
        .hideToolBar(true)
      }
      .tabBar(this.tabBarBuilder('我的', '👤', 1))
    }
    .onChange((index: number) => { this.currentIndex = index })
  }
}

// Detail page shared by both Tabs.
@Component
export struct DetailPage {
  @State from: string = ''
  // Bound to whichever stack this page actually belongs to, in onReady.
  pathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Column() {
        Text(`来自：${this.from}`).fontSize(18)
        Button('返回').margin({ top: 20 })
          .onClick(() => { this.pathStack.pop() })
      }
      .width('100%').height('100%').justifyContent(FlexAlign.Center)
    }
    .title('详情')
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack // the real stack (home / mine both correct)
      const p = ctx.pathInfo?.param as Record<string, string>
      if (p) { this.from = p['from'] ?? '' }
    })
  }
}
