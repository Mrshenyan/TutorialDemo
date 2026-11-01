import { router } from '@kit.ArkUI'

// Chapter 48 landing page: Sendable.
// Order: show what a thread boundary really does (copy), then how to share.
@Entry
@Component
struct Ch48Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第48篇：Sendable 跨线程对象')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('第 37 篇讲了 @Concurrent 和 Worker，但有个问题一直没回答：传给子线程的那个对象，到底过去了什么？这一篇把「拷贝」和「共享」两件事分别跑一遍。')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        Text('① 普通对象：过线程就是拷贝')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('看拷贝到底怎么隔离')
          .width('92%')
          .backgroundColor('#C62828')
          .onClick(() => router.pushUrl({ url: 'pages/ch48/Ch48Clone' } as router.RouterOptions))

        Text('② @Sendable：过线程还是同一个对象')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('看共享内存的效果')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch48/Ch48Share' } as router.RouterOptions))

        Text('③ Sendable 容器：collections.Map')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('子线程改同一个 Map')
          .width('92%')
          .backgroundColor('#6A1B9A')
          .onClick(() => router.pushUrl({ url: 'pages/ch48/Ch48Collections' } as router.RouterOptions))

        Text('④ 拷贝的代价：实测耗时对比')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('跑一次性能对比')
          .width('92%')
          .backgroundColor('#EF6C00')
          .onClick(() => router.pushUrl({ url: 'pages/ch48/Ch48Perf' } as router.RouterOptions))

        Text('注意：@Concurrent 函数必须在文件顶层，不能碰 this，也不能引用外部变量——它要用的东西全部靠参数传进去。')
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
