import { router } from '@kit.ArkUI'

// Chapter 51 landing page: advanced transitions.
// All four demos are NEW ground — ch20 already covered animation()/animateTo()/
// transition()/sharedTransition()/pageTransition(), ch29 covered spring curves and
// keyframeAnimateTo. This chapter adds geometryTransition, bindContentCover,
// motionPath and @AnimatableExtend on top of that base.
@Entry
@Component
struct Ch51Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第51篇：转场动画进阶——一镜到底与自绘动效')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('ch20 讲过 sharedTransition（跨页面飞）、ch29 讲过弹簧曲线。这一篇全是新东西：geometryTransition 同页一镜到底、bindContentCover 自定义模态转场、motionPath 路径动画、@AnimatableExtend 把不可动画的属性包成可动画。')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        Text('① geometryTransition：一镜到底')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('点缩略图，图片原地长成全屏')
          .width('92%')
          .backgroundColor('#1565C0')
          .onClick(() => router.pushUrl({ url: 'pages/ch51/Ch51Geometry' } as router.RouterOptions))

        Text('② bindContentCover：自定义模态转场')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('全屏浮层，转场自己说了算')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch51/Ch51Modal' } as router.RouterOptions))

        Text('③ motionPath：沿路径飞行')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('小球沿 S 曲线飞，还能转头')
          .width('92%')
          .backgroundColor('#6A1B9A')
          .onClick(() => router.pushUrl({ url: 'pages/ch51/Ch51MotionPath' } as router.RouterOptions))

        Text('④ @AnimatableExtend：自定义可动画属性')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('把 fontSize 包一层，animation() 就认了')
          .width('92%')
          .backgroundColor('#C62828')
          .onClick(() => router.pushUrl({ url: 'pages/ch51/Ch51AnimExtend' } as router.RouterOptions))

        Text('本章全部 API 在 ch20/ch29 都没出现过；每个页面都是独立可玩的小实验，动画效果建议真机/模拟器逐个点。')
          .fontSize(12)
          .fontColor('#888')
          .width('92%')
          .margin({ top: 10 })

        Button('返回首页')
          .width('92%')
          .margin({ top: 16 })
          .onClick(() => router.back())
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }
}
