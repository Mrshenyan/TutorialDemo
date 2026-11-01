// Chapter 47 §四: @Monitor (multi-path + before/now) and @Computed (cached).
//
// The cache proof lives on screen: static counters that are NOT part of any
// state system. Tap "改无关状态" a few times -- the plain method's counter keeps
// climbing (it runs on every rebuild), while @Computed's counter stays put.
import { Ch47Stats } from '../ch47data/Ch47Stats'

@Entry
@ComponentV2
struct Ch47MonitorComputedPage {
  @Local price: number = 100
  @Local count: number = 2
  // Unrelated state, used as a rebuild trigger for the cache experiment.
  @Local note: number = 0
  @Local watchLog: string[] = []

  // @Computed: cached. Recomputed only when price or count changes.
  @Computed
  get total(): number {
    // Demo probe only (see Ch47Stats). A real @Computed should stay pure.
    Ch47Stats.computedHits += 1
    return this.price * this.count
  }

  // A plain method: runs on EVERY rebuild, no matter what changed.
  plainTotal(): number {
    Ch47Stats.plainHits += 1
    return this.price * this.count
  }

  // @Monitor takes multiple paths at once and hands you before / now.
  @Monitor('price', 'count')
  onValueChanged(monitor: IMonitor): void {
    let line: string = `dirty = [${monitor.dirty.join(', ')}]`
    const p: IMonitorValue<number> | undefined = monitor.value<number>('price')
    if (p !== undefined) {
      line += ` | price ${p.before} -> ${p.now}`
    }
    const c: IMonitorValue<number> | undefined = monitor.value<number>('count')
    if (c !== undefined) {
      line += ` | count ${c.before} -> ${c.now}`
    }
    this.watchLog = this.watchLog.concat([line])
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('@Monitor + @Computed')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })

        Text('V1 的 @Watch 只能挂一个属性、只给新值；V2 的 @Monitor 能一次盯多条路径，还能拿到 before / now。')
          .fontSize(12)
          .fontColor('#888')
          .width('92%')

        // ---------- Monitor ----------
        Column({ space: 8 }) {
          Text(`price = ${this.price}　count = ${this.count}`).fontSize(14).fontColor('#2E7D32')
          Row({ space: 10 }) {
            Button('price +10').onClick(() => {
              this.price += 10
            })
            Button('count +1').onClick(() => {
              this.count += 1
            })
          }
          Text('注意日志里的细节：只改 price 时，count 的 before / now 也照样出现（都等于旧值）。判断「到底谁变了」要看 dirty，不是看 value() 有没有返回。')
            .fontSize(11)
            .fontColor('#C62828')
          ForEach(this.watchLog, (line: string, idx: number) => {
            Text(`${idx + 1}. ${line}`).fontSize(11).fontColor('#555').width('100%')
          }, (line: string, idx: number) => `${idx}-${line}`)
          if (this.watchLog.length === 0) {
            Text('还没有记录，点上面两个按钮').fontSize(11).fontColor('#999')
          }
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#E8F5E9')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        // ---------- Computed ----------
        Column({ space: 8 }) {
          Text('@Computed 缓存实验').fontSize(15).fontWeight(FontWeight.Medium)
          Text(`@Computed total = ${this.total}`).fontSize(14).fontColor('#317af7')
          Text(`普通方法 plainTotal() = ${this.plainTotal()}`).fontSize(14).fontColor('#B71C1C')

          // The probe line depends on note AND on both calculations. Changing
          // note forces this line to re-evaluate, which is the only way to see
          // who actually recomputes and who just reads a cached value.
          Text(`计算探针（依赖 note）：computed=${this.total} / plain=${this.plainTotal()} / note=${this.note}`)
            .fontSize(12)
            .fontColor('#6A1B9A')
            .width('100%')

          Text(`note=${this.note} → @Computed 重算 ${Ch47Stats.computedHits} 次 / 普通方法执行 ${Ch47Stats.plainHits} 次`)
            .fontSize(12)
            .fontColor('#C62828')
            .width('100%')

          Text(`无关状态 note = ${this.note}`).fontSize(13).fontColor('#888')
          Button('改无关状态 note +1').onClick(() => {
            this.note += 1
          })
          Text('点上面这个按钮：探针行会被重建，普通方法又算了一遍（执行次数 +1），@Computed 纹丝不动（重算次数不变）——它认得自己的依赖。')
            .fontSize(11)
            .fontColor('#999')
          Text('注意：只有依赖 note 的那几行会重建，页面并不是整体刷新。ArkUI 的更新粒度是「组件级依赖」，这也是为什么必须让探针行同时依赖 note。')
            .fontSize(11)
            .fontColor('#C62828')
          Text('两个计数器是静态变量，不参与状态管理，所以它们本身不会引起刷新，只反映真实执行次数。')
            .fontSize(11)
            .fontColor('#888')
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#E3F2FD')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('什么时候才该用 @Computed').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#6A1B9A')
          Text('依赖少、计算便宜（字符串拼接、求和）用普通 getter 就行；依赖多、计算重（过滤排序、复杂汇总）才值得上 @Computed。它是缓存，不是免费的。')
            .fontSize(11)
            .fontColor('#555')
            .width('100%')
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#F3E5F5')
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
