import { router } from '@kit.ArkUI';

// Chapter 29 landing page: links to the gesture + animation demos.
@Entry
@Component
struct Ch29Index {
  build() {
    Column({ space: 16 }) {
      Text('第29篇：手势与动画联动')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('手势驱动数字、动画驱动过渡：animateTo 显式动画 / animation 属性动画 / 曲线与回弹')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('① 手势 + 动画联动（图片查看器升级版）')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch29/GestureAnimDemo' } as router.RouterOptions))

      Button('② 属性动画 animation()（顺序敏感）')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch29/PropertyAnimDemo' } as router.RouterOptions))

      Button('③ 显式动画 animateTo 与曲线')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch29/ExplicitAnimDemo' } as router.RouterOptions))

      Button('④ 高级使用（跟手弹簧/关键帧/Animator/性能）')
        .width('85%')
        .backgroundColor('#6A1B9A')
        .onClick(() => router.pushUrl({ url: 'pages/ch29/AdvancedAnimDemo' } as router.RouterOptions))

      Button('返回首页')
        .width('85%')
        .margin({ top: 16 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
