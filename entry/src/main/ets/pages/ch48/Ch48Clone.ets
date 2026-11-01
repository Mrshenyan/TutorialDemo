// Chapter 48 §一: a plain object handed to taskpool is COPIED, not shared.
// The worker bumps its own copy to 101, the caller's object stays at 1.
import { taskpool } from '@kit.ArkTS'
import { PlainCounter } from '../ch48data/Ch48Models'
import { bumpPlain } from '../ch48data/Ch48Tasks'

@Entry
@ComponentV2
struct Ch48ClonePage {
  // Deliberately a plain member, not @Local: this page is about cross-thread
  // semantics, and we do not want state management to blur the picture.
  private counter: PlainCounter = new PlainCounter(1)
  @Local displayValue: number = 1
  // What the worker thread returned.
  @Local returned: number = 0
  @Local log: string[] = []

  async runOnce(): Promise<void> {
    const r: number = await taskpool.execute(bumpPlain, this.counter) as number
    this.returned = r
    // Re-read the caller's object AFTER the worker finished.
    this.displayValue = this.counter.value
    this.log = this.log.concat([`子线程返回 ${r}，主线程 counter.value = ${this.counter.value}`])
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('普通对象：过线程就是一份拷贝')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })

        Text('taskpool 拿到普通 class 实例时，会做一次结构化克隆：内存里变成两份。子线程改的是它那份，主线程这份一动不动。')
          .fontSize(12)
          .fontColor('#888')
          .width('92%')

        Column({ space: 8 }) {
          Text(`主线程 counter.value = ${this.displayValue}`).fontSize(16).fontColor('#2E7D32')
          Text(`子线程 return 值 = ${this.returned}`).fontSize(16).fontColor('#B71C1C')
          Button('丢给 taskpool 跑 +100').onClick(() => {
            this.runOnce()
          })
          Text('点几次你会发现：返回值永远是 101，主线程那个值永远是 1。子线程每次拿到的都是同一份「1 的副本」，改完就随任务一起丢掉，主线程这份从头到尾没被碰过。')
            .fontSize(11)
            .fontColor('#999')
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#FFF3E0')
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
          Text('这意味着什么').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#C62828')
          Text('拷贝不是坏事：它天然隔离，子线程怎么折腾都污染不到主线程。代价是——对象越大，拷贝越贵；而且主线程想拿结果，只能靠返回值。')
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
