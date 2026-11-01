import { router } from '@kit.ArkUI'

// Chapter 47 landing page: state management V2.
// Order matters: reproduce the V1 pain first, then fix it section by section.
@Entry
@Component
struct Ch47Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第47篇：状态管理 V2')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('V1 的 @State / @Prop / @Observed 为什么不够用？这一篇先把手感最差的三个坑复现出来，再用 V2 的 12 个装饰器一个一个补上。')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        Text('① V1 的三种「我明明改了」')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('复现 V1 的坑')
          .width('92%')
          .backgroundColor('#C62828')
          .onClick(() => router.pushUrl({ url: 'pages/ch47/Ch47Pain' } as router.RouterOptions))

        Text('② @ObservedV2 + @Trace 修深层')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('外层嵌套 + Map')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch47/Ch47Trace' } as router.RouterOptions))

        Text('③ @Param / @Once / @Event / @Require')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('父子通信四种装饰器')
          .width('92%')
          .backgroundColor('#6A1B9A')
          .onClick(() => router.pushUrl({ url: 'pages/ch47/Ch47ParamEvent' } as router.RouterOptions))

        Text('④ @Monitor + @Computed')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('多路径监听与缓存计算')
          .width('92%')
          .backgroundColor('#EF6C00')
          .onClick(() => router.pushUrl({ url: 'pages/ch47/Ch47MonitorComputed' } as router.RouterOptions))

        Text('⑤ @Provider / @Consumer')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('跨三层传值')
          .width('92%')
          .backgroundColor('#00838F')
          .onClick(() => router.pushUrl({ url: 'pages/ch47/Ch47ProviderConsumer' } as router.RouterOptions))

        Text('注意：V1 和 V2 装饰器不能混用在同一个组件里。@Component 里出现 @Local / @Param 会直接编译报错，反之 @ComponentV2 里也不能写 @State / @Prop。')
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
