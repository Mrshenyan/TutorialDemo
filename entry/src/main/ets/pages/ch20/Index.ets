import { router } from '@kit.ArkUI'

// Chapter 20 landing page: animation & transition.
@Entry
@Component
struct Ch20Index {
  build() {
    Column({ space: 16 }) {
      Text('第20篇：动画与转场')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('动画 = 状态变化的可视化，底层还是 @State')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('animation()：属性动画')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch20/AnimBasic' }))

      Button('animateTo()：显式动画')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch20/AnimExplicit' }))

      Button('transition()：组件出现/消失')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch20/TransitionDemo' }))

      Button('sharedTransition()：共享元素')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch20/SharedA' }))

      Button('pageTransition()：整页切换')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch20/PageTransitionA' }))

      Button('点赞动画实战')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch20/LikeDemo' }))

      Button('返回首页')
        .width('85%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
