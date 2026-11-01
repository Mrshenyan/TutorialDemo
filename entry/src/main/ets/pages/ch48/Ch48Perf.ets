// Chapter 48 §四: the price tag of copying, measured on device.
//
// Two separate experiments, because "shared" is not automatically "faster":
//   A. transfer only  -- worker just reads .length, so the number is dominated
//                        by moving data across the boundary.
//   B. traverse+sum   -- worker touches every element, so the number is
//                        dominated by per-element access cost inside the worker.
// Real measurements on the emulator showed A favours sharing and B favours the
// plain array. Both are worth knowing before you "optimise".
import { collections, taskpool } from '@kit.ArkTS'
import { sumPlain, sumSendable, peekPlainLength, peekSendableLength } from '../ch48data/Ch48Tasks'

@Entry
@ComponentV2
struct Ch48PerfPage {
  @Local elementCount: number = 300000
  @Local copyMs: number = 0
  @Local shareMs: number = 0
  @Local copySumMs: number = 0
  @Local shareSumMs: number = 0
  @Local checkSum: number = 0
  @Local busy: boolean = false
  @Local note: string = '点下面的按钮跑一次，多点几次看稳定值'

  async runTest(): Promise<void> {
    if (this.busy) {
      return
    }
    this.busy = true
    this.note = '跑着呢…'

    const plain: number[] = []
    const shared: collections.Array<number> = new collections.Array<number>()
    for (let i = 0; i < this.elementCount; i++) {
      plain.push(i)
      shared.push(i)
    }

    // Experiment A: transfer only.
    let t0: number = Date.now()
    await taskpool.execute(peekPlainLength, plain)
    this.copyMs = Date.now() - t0

    t0 = Date.now()
    await taskpool.execute(peekSendableLength, shared)
    this.shareMs = Date.now() - t0

    // Experiment B: traverse every element.
    t0 = Date.now()
    this.checkSum = await taskpool.execute(sumPlain, plain) as number
    this.copySumMs = Date.now() - t0

    t0 = Date.now()
    await taskpool.execute(sumSendable, shared)
    this.shareSumMs = Date.now() - t0

    this.note = '两组都跑完了，看下面的结论'
    this.busy = false
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('拷贝的代价，和共享的代价')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })

        Text('同一个数组，传给子线程有两种方式。我把「只传输」和「遍历访问」拆成两组测，因为这两个成本的方向相反。')
          .fontSize(12)
          .fontColor('#888')
          .width('92%')

        Column({ space: 8 }) {
          Text(`元素个数：${this.elementCount}`).fontSize(14).fontColor('#888')
          Button(this.busy ? '跑着呢…' : '跑一次对比').enabled(!this.busy).onClick(() => {
            this.runTest()
          })
          Text(this.note).fontSize(12).fontColor('#6A1B9A')
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#E3F2FD')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('A. 只传输（子线程只读 length）').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#317af7')
          Text(`number[] 拷贝过去：${this.copyMs} ms`).fontSize(14).fontColor('#B71C1C')
          Text(`collections.Array 共享过去：${this.shareMs} ms`).fontSize(14).fontColor('#2E7D32')
          Text('这组测的是「搬数据」本身。30 万个 number，拷贝版要复制一整块内存，共享版只传个引用。差距主要在这里。')
            .fontSize(11).fontColor('#999')
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#E8F5E9')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('B. 全量遍历求和').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#EF6C00')
          Text(`number[]：${this.copySumMs} ms（和 = ${this.checkSum}）`).fontSize(14).fontColor('#B71C1C')
          Text(`collections.Array：${this.shareSumMs} ms`).fontSize(14).fontColor('#2E7D32')
          Text('这组测的是「子线程里访问元素的成本」。collections.Array 每个下标访问都要过一层运行时检查，30 万次累加起来，可能比一次 memcpy 还贵。')
            .fontSize(11).fontColor('#999')
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#FFF3E0')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('实测结论（比我预想的反直觉）').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#C62828')
          Text('我原本以为「共享一定更快」，实测打脸：A 组共享明显占优，B 组反而是普通数组更快。')
            .fontSize(11).fontColor('#555').width('100%')
          Text('原因不复杂：拷贝是一次性 memcpy，很快；collections.Array 的下标访问有额外开销，遍历次数一多就反超。')
            .fontSize(11).fontColor('#555').width('100%')
          Text('所以别背「Sendable 性能更好」这种结论。数据大、子线程只做少量操作 → 共享划算；子线程要反复遍历 → 先把拷贝的代价和访问的代价都量一遍再决定。')
            .fontSize(11).fontColor('#555').width('100%')
          Text('另外：绝对毫秒数受设备、编译模式、冷启动影响，看同一台机器上的相对关系就够了。')
            .fontSize(11).fontColor('#888').width('100%')
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
