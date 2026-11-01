// Chapter 47 §二: @ObservedV2 + @Trace fix the nesting problem with ONE class.
// Compare with ch15: that version needed one extra component and one extra
// @ObjectLink per nested level. Here the whole three-level object stays tracked.
//
// Also note: @Trace is a whitelist. Fields without it stay invisible on purpose.
import { V2User } from '../ch47data/Ch47Models'

@Entry
@ComponentV2
struct Ch47TracePage {
  // @Local replaces @State, and it observes objects / arrays / Map / Set deeply.
  @Local user: V2User = new V2User('小明', '深圳')
  @Local stock: Map<string, number> = new Map<string, number>([['苹果', 3]])
  @Local traceHint: string = ''

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('@ObservedV2 + @Trace：一个类搞定深层')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })
          .width('92%')
          .textAlign(TextAlign.Center)

        Text('同样的三层对象，V1 要「2 个 @Observed 类 + 2 个子组件 + 2 个 @ObjectLink」；V2 只要一个 @ObservedV2 类，把关心的字段标上 @Trace。')
          .fontSize(12)
          .fontColor('#888')
          .width('92%')

        // ---------- Nested object ----------
        Column({ space: 8 }) {
          Text('① 三层嵌套，直接改直接刷').fontSize(15).fontWeight(FontWeight.Medium)
          Text(`姓名：${this.user.name}`).fontSize(14)
          Text(`城市：${this.user.address.city}`).fontSize(14).fontColor('#2E7D32')
          Text(`邮编（故意没标 @Trace）：${this.user.address.zipCode}`).fontSize(14).fontColor('#B71C1C')
          Text('同一行代码，V1 里点了没反应，V2 里点了立刻变。区别不在写法，在于对象本身是不是「被追踪的」。')
            .fontSize(11)
            .fontColor('#999')
          Row({ space: 10 }) {
            Button('改城市（有 @Trace）').onClick(() => {
              this.user.address.city = this.user.address.city === '深圳' ? '上海' : '深圳'
              this.traceHint = 'city 标了 @Trace，界面立刻刷新'
            })
          }
          Row({ space: 10 }) {
            Button('改邮编（没 @Trace）').onClick(() => {
              this.user.address.zipCode = this.user.address.zipCode === '518000' ? '200000' : '518000'
              this.traceHint = 'zipCode 没标 @Trace，界面不会动 —— 这就是白名单的含义'
            })
          }
          Text(this.traceHint).fontSize(11).fontColor('#C62828')
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#E8F5E9')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        // ---------- Map ----------
        Column({ space: 8 }) {
          Text('② Map：set 完直接刷').fontSize(15).fontWeight(FontWeight.Medium)
          Text(`苹果库存：${this.stock.get('苹果') ?? 0}`).fontSize(14).fontColor('#2E7D32')
          Text('@Local 修饰的 Map 会被深度观察，set 完直接刷。V1 从 API 11 起其实也支持观察 Map/Set，所以这一条不算 V2 的独有优势——V2 真正的增量是 @Trace：它把「观察哪个字段」变成显式声明，深层对象、Map、Set、Date 一视同仁。')
            .fontSize(11)
            .fontColor('#999')
          Row({ space: 10 }) {
            Button('库存 +1').onClick(() => {
              const cur: number = this.stock.get('苹果') ?? 0
              this.stock.set('苹果', cur + 1)
            })
            Button('清空').onClick(() => {
              this.stock.clear()
            })
          }
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#E3F2FD')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        // ---------- Kernel rule ----------
        Column({ space: 6 }) {
          Text('一条硬规则').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#C62828')
          Text('@ObservedV2 / @Trace / @Local / @Param / @Once / @Event / @Monitor / @Computed / @Provider / @Consumer 只能出现在 @ComponentV2 组件里；@Component 里用不了，反之亦然。混用直接编译报错，这是 V2 最容易被卡住的地方。')
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
