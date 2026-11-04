import { router } from '@kit.ArkUI'

// Chapter 49 landing page: long-list performance.
// Order: measure the waste, remove it, then meet the two traps.
@Entry
@Component
struct Ch49Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第49篇：长列表性能——组件复用到底省了什么')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('第 16 篇给过 @Reusable 的写法，但没回答三个问题：到底省了多少、什么时候会翻车、数据变了还对不对。这一篇用 300 条真实长度的列表，把构造次数一个一个数出来。')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        Text('① 基线：同一个 ForEach，两种容器')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('看 List 和 Column 差多少')
          .width('92%')
          .backgroundColor('#C62828')
          .onClick(() => router.pushUrl({ url: 'pages/ch49/Ch49Baseline' } as router.RouterOptions))

        Text('② 换成 LazyForEach + @Reusable')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('同样 300 条，看构造次数')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch49/Ch49Reuse' } as router.RouterOptions))

        Text('③ 坑一：复用把上一条的状态带过来了')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('点赞串位现场')
          .width('92%')
          .backgroundColor('#E65100')
          .onClick(() => router.pushUrl({ url: 'pages/ch49/Ch49Pitfall' } as router.RouterOptions))

        Text('④ 坑二：数据增删之后复用还对不对')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('增删改 + key 的规矩')
          .width('92%')
          .backgroundColor('#6A1B9A')
          .onClick(() => router.pushUrl({ url: 'pages/ch49/Ch49Tuning' } as router.RouterOptions))

        Text('两个前提：LazyForEach 的 key 必须是稳定的业务 id（不能是下标），@Reusable 的数据必须全部从 aboutToReuse 的 params 里重新拿。这两条做到了，复用才是净赚。')
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
