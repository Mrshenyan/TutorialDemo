import { router } from '@kit.ArkUI'

// Chapter 18 landing page: Tabs (bottom navigation bar).
@Entry
@Component
struct Ch18Index {
  build() {
    Column({ space: 16 }) {
      Text('第18篇：Tabs 底部导航栏')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('Tabs 是壳，TabContent 是内容，.tabBar 是按钮')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('最小可用：底部三个 Tab')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch18/BasicTabs' }))

      Button('自定义 tabBar：图标 + 文字 + 选中态 + 角标')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch18/IconTabs' }))

      Button('TabsController：代码切换 Tab')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch18/ControllerTabs' }))

      Button('Tab + Navigation：每个 Tab 独立栈')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch18/AppShell' }))

      Button('返回首页')
        .width('85%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
