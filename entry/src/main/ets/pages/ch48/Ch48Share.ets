// Chapter 48 §二: a @Sendable instance crosses the thread boundary as-is.
// The worker bumps the SAME memory, so the caller sees 101 right after.
import { taskpool } from '@kit.ArkTS'
import { SharedCounter } from '../ch48data/Ch48Models'
import { bumpShared } from '../ch48data/Ch48Tasks'

@Entry
@ComponentV2
struct Ch48SharePage {
  private counter: SharedCounter = new SharedCounter(1)
  @Local displayValue: number = 1
  @Local returned: number = 0
  @Local log: string[] = []

  async runOnce(): Promise<void> {
    const r: number = await taskpool.execute(bumpShared, this.counter) as number
    this.returned = r
    // Same instance, so the bump is already visible here.
    this.displayValue = this.counter.value
    this.log = this.log.concat([`子线程返回 ${r}，主线程 counter.value = ${this.counter.value}`])
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('@Sendable：过线程还是同一个对象')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })

        Text('把 class 标成 @Sendable，跨线程传的就是引用，不再克隆。子线程改完，主线程立刻能看到——但也意味着两边在抢同一块内存。')
          .fontSize(12)
          .fontColor('#888')
          .width('92%')

        Column({ space: 8 }) {
          Text(`主线程 counter.value = ${this.displayValue}`).fontSize(16).fontColor('#2E7D32')
          Text(`子线程 return 值 = ${this.returned}`).fontSize(16).fontColor('#B71C1C')
          Button('丢给 taskpool 跑 +100').onClick(() => {
            this.runOnce()
          })
          Text('连点三次：两个数字一路同步涨到 101、201、301。上一页的主线程值永远停在 1，这一页会跟着跑。')
            .fontSize(11)
            .fontColor('#999')
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#E8F5E9')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('执行日志').fontSize(14).fontWeight(FontWeight.Medium)
          ForEach(this.log, (line: string, idx: number) => {
            Text(`${idx + 1}. ${line}`).fontSize(11).fontColor('#555').width('100%')
          }, (line: string, idx: number) => `${idx}-${line}`)
          if (this.log.length === 0) {
            Text('还没有记录，点上面的按钮').fontSize(11).fontColor('#999')
          }
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('共享 ≠ 安全').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#C62828')
          Text('两个 taskpool 任务同时改同一个 @Sendable 对象，读写顺序就没有保证了。真要并发写，得自己设计同步（比如把写操作串到一个队列里，或者用 Atomics 处理 SharedArrayBuffer）。这一页只跑单个任务，所以看不出问题——生产代码里这才是最容易出事的地方。')
            .fontSize(11)
            .fontColor('#555')
            .width('100%')
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#FFEBEE')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 24 })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }
}
