// Chapter 47 §一: three V1 pain points you can reproduce with your own hands.
// Every button here writes the data but leaves the UI untouched -- that gap
// is exactly why ArkUI shipped V2 state management.
//
// How to read this page:
//   Card 1: tap "改城市" -> the city line stays 深圳. Tap "读内存真实值" -> it
//           prints 上海. The value was written long ago; V1 never noticed.
//   Card 2: tap "子 +1" -> the child shows 101 while the parent still shows 100.
//           @Prop is a copy, not a reference.
//   Card 3: tap "价格 +20" twice -> the log only ever says "现在是 120/140".
//           @Watch has no idea what the old value was.
import { V1User } from '../ch47data/Ch47Models'

// Card 2's child: @Prop receives a COPY of the parent's number.
@Component
struct Ch47PropChild {
  @Prop score: number = 0

  build() {
    Column({ space: 6 }) {
      Text(`子组件 @Prop score = ${this.score}`).fontSize(14).fontColor('#B71C1C')
      Button('子 +1').fontSize(12).height(32).onClick(() => {
        // Legal in V1: @Prop can be edited locally, it just never goes back up.
        this.score += 1
      })
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#FFFFFF')
    .borderRadius(6)
    .alignItems(HorizontalAlign.Start)
  }
}

@Entry
@Component
struct Ch47PainPage {
  // Pain 1: @State only observes the FIRST layer of an object.
  @State user: V1User = new V1User('小明', '深圳')
  // Pain 2: @Prop copies the value down, and never copies it back up.
  @State score: number = 100
  // Pain 3: @Watch gives you the new value only, never the old one.
  @State @Watch('onPriceChange') price: number = 100

  @State logs: string[] = []
  // Reading the raw field into a separate @State is the only honest way to
  // show "the value is already new" while the bound Text is still stale.
  @State memRead: string = '（还没读，点按钮试试）'

  onPriceChange(): void {
    // Only the property name is delivered; the old value is already gone.
    this.logs = this.logs.concat([`@Watch 触发：price 现在是 ${this.price}，旧值？拿不到`])
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('V1 的三种「我明明改了」')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })

        Text('下面每个按钮都真的改了数据，但界面对应的那一行不会动。三张卡片分别对应三种「数据流断了」的方式。')
          .fontSize(12)
          .fontColor('#888')
          .width('92%')

        // ---------- Pain 1 ----------
        Column({ space: 8 }) {
          Text('① 嵌套对象：第二层改了不刷新').fontSize(15).fontWeight(FontWeight.Medium)
          Text(`姓名：${this.user.name}`).fontSize(14)
          Text(`城市：${this.user.address.city}`).fontSize(14).fontColor('#2E7D32')
          Text('@State 只观察到 user 的第一层（name / address 的引用）。address.city 在第二层，V1 里必须再拆一个 @ObjectLink 子组件才能观察到——而且光靠别的状态触发重建也没用，这一行压根没建立依赖。')
            .fontSize(11)
            .fontColor('#999')
          Row({ space: 10 }) {
            Button('改城市').onClick(() => {
              this.user.address.city = this.user.address.city === '深圳' ? '上海' : '深圳'
            })
            Button('读内存真实值').onClick(() => {
              this.memRead = `address.city = ${this.user.address.city}`
            })
          }
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#FFF3E0')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        // ---------- Pain 2 ----------
        Column({ space: 8 }) {
          Text('② @Prop 是拷贝：子改父不知道').fontSize(15).fontWeight(FontWeight.Medium)
          Text(`父组件 @State score = ${this.score}`).fontSize(14).fontColor('#2E7D32')
          Text('@Prop 把值「复制」一份给子组件。子组件改自己的那份完全合法，但父组件手里的原件不动——想回传？只能再挂一个回调，V1 里没有任何机制帮你做这件事。')
            .fontSize(11)
            .fontColor('#999')
          Ch47PropChild({ score: this.score })
          Button('父 +1（子会跟着变）').onClick(() => {
            this.score += 1
          })
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#E3F2FD')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        // ---------- Pain 3 ----------
        Column({ space: 8 }) {
          Text('③ @Watch：只给新值，拿不到旧值').fontSize(15).fontWeight(FontWeight.Medium)
          Text(`价格：${this.price}`).fontSize(14).fontColor('#2E7D32')
          Text('想写「从 100 涨到 120」这种文案？@Watch 回调只告诉你哪个属性变了，旧值得自己额外拿个变量存着。')
            .fontSize(11)
            .fontColor('#999')
          Button('价格 +20').onClick(() => {
            this.price += 20
          })
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#F3E5F5')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        // ---------- Memory readout ----------
        Column({ space: 6 }) {
          Text('内存真实值').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#C62828')
          Text(this.memRead).fontSize(13).fontColor('#C62828').width('100%')
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#FFEBEE')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        // ---------- Live log ----------
        Column({ space: 6 }) {
          Text('实时日志').fontSize(14).fontWeight(FontWeight.Medium)
          ForEach(this.logs, (line: string, idx: number) => {
            Text(`${idx + 1}. ${line}`).fontSize(11).fontColor('#555').width('100%')
          }, (line: string, idx: number) => `${idx}-${line}`)
          if (this.logs.length === 0) {
            Text('还没有日志，点「价格 +20」试试').fontSize(11).fontColor('#999')
          }
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#FAFAFA')
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
