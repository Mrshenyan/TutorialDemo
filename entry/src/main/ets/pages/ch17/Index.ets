import { router } from '@kit.ArkUI'

// Chapter 17 landing page: Navigation (page navigation).
@Entry
@Component
struct Ch17Index {
  build() {
    Column({ space: 16 }) {
      Text('第17篇：Navigation 页面导航')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('Navigation + NavPathStack + NavDestination 取代老 Router')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('最小例子：点按钮推开子页面')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch17/BasicNav' }))

      Button('Tab + Navigation：每个 Tab 独立栈')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch17/TabNav' }))

      Button('返回拦截：编辑未保存提醒')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch17/BackIntercept' }))

      Button('返回首页')
        .width('85%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
