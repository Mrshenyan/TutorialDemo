// Chapter 17 §二: minimal Navigation example.
// Three roles: Navigation (container) + NavPathStack (the stack) +
// NavDestination (each pushed page must be wrapped in it).

interface NavParam {
  id: string
  title: string
}

@Entry
@Component
struct MainPage {
  // The stack: all navigation ops go through it. Exposed to children via @Provide.
  @Provide pageStack: NavPathStack = new NavPathStack()

  // ★ Critical: the navDestination builder maps a route name to a page.
  // Without it, pushPathByName leads to a blank page.
  @Builder
  PageMap(name: string) {
    if (name === 'PageOne') {
      PageOne()
    }
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Text('我是首页')
          .fontSize(24)
          .margin({ top: 100 })

        Button('去详情页')
          .margin({ top: 20 })
          .onClick(() => {
            // pushPathByName: open by name (must match PageMap's condition)
            let param: NavParam = { id: 'PageOne', title: '一篇好文章' }
            this.pageStack.pushPathByName('PageOne', param)
          })
      }
      .width('100%')
      .height('100%')
    }
    .title('首页')
    .mode(NavigationMode.Stack)   // Stack mode: pushes with a back button
    .navDestination(this.PageMap) // mount the builder so jumps can find the page
  }
}

@Component
export struct PageOne {
  // Receive the same stack shared by the entry via @Consume.
  @Consume pageStack: NavPathStack
  @State articleId: string = ''
  @State articleTitle: string = ''

  build() {
    NavDestination() {
      Column() {
        Text(`文章ID：${this.articleId}`)
          .fontSize(18)
        Text(`标题：${this.articleTitle}`)
          .fontSize(18)
          .margin({ top: 8 })

        Button('返回')
          .margin({ top: 30 })
          .onClick(() => {
            this.pageStack.pop() // pop = go back
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .title('详情页')
    .onReady((context: NavDestinationContext) => {
      // Params are read in onReady, not aboutToAppear (may not be ready yet).
      const params = context.pathInfo?.param as Record<string, string>
      if (params) {
        this.articleId = params['id'] ?? ''
        this.articleTitle = params['title'] ?? ''
      }
    })
  }
}
