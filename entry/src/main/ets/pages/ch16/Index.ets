import { router } from '@kit.ArkUI'

// Chapter 16 landing page: ForEach / LazyForEach / @Reusable.
@Entry
@Component
struct Ch16Index {
  build() {
    Column({ space: 16 }) {
      Text('第16篇：ForEach 与 LazyForEach')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('列表渲染：中小列表用 ForEach，长列表用 LazyForEach + 复用')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('ForEach：循环渲染 + 稳定 key')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch16/ForEachDemo' }))

      Button('LazyForEach：数据懒加载（IDataSource）')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch16/LazyForEachDemo' }))

      Button('LazyForEach + @Reusable 组件复用')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch16/ReusableDemo' }))

      Button('返回首页')
        .width('85%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
