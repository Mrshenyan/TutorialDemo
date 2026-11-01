// Chapter 47 §三: @Param / @Once / @Event / @Require -- the whole parent-child
// handshake, and the one place V2 differs most from V1: @Param passes by
// reference, @Prop copies.
import { V2User } from '../ch47data/Ch47Models'

// Child card. All four decorators show up here on purpose.
@ComponentV2
struct Ch47ParamCard {
  // @Require: forgetting to pass this at the call site is a COMPILE error.
  @Require @Param title: string
  // @Param: synced from parent, read-only here. `this.value = 1` would not compile.
  @Param value: number = 0
  // @Param + @Once: takes the parent's value ONE time, then lives its own life.
  @Param @Once seed: number = 0
  // @Event: the child's only legal way to ask the parent to change something.
  @Event onAdd: (delta: number) => void = (delta: number) => {}
  // @Param on an @ObservedV2 instance = by reference, no copy.
  @Param user: V2User = new V2User('子组件默认', '北京')

  build() {
    Column({ space: 6 }) {
      Text(this.title).fontSize(14).fontWeight(FontWeight.Medium)
      Text(`@Param value = ${this.value}`).fontSize(13)
      Text(`@Param @Once seed = ${this.seed}`).fontSize(13).fontColor('#6A1B9A')
      Text(`@Param user.city = ${this.user.address.city}`).fontSize(13).fontColor('#2E7D32')

      Row({ space: 8 }) {
        Button('seed 本地 +1').fontSize(11).height(30).onClick(() => {
          // Legal only because of @Once: the value is no longer parent-owned.
          this.seed += 1
        })
        Button('通知父 +1').fontSize(11).height(30).onClick(() => {
          this.onAdd(1)
        })
      }

      Button('直接改 user.city（引用传递）').fontSize(11).height(30).onClick(() => {
        // Changing a field of the object is allowed; only rebinding is not.
        this.user.address.city = this.user.address.city === '深圳' ? '上海' : '深圳'
      })
    }
    .width('92%')
    .padding(12)
    .backgroundColor('#F3E5F5')
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
  }
}

@Entry
@ComponentV2
struct Ch47ParamEventPage {
  @Local total: number = 0
  @Local seedFromParent: number = 100
  @Local user: V2User = new V2User('小明', '深圳')

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('@Param / @Once / @Event / @Require')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })

        Text('V1 要在 @Prop（深拷贝）和 @Link（双向引用）之间做选择；V2 把「读」和「写」拆开：@Param 只读、@Event 才能写。规则更死，坑也更少。')
          .fontSize(12)
          .fontColor('#888')
          .width('92%')

        Text(`父组件 total = ${this.total}　seedFromParent = ${this.seedFromParent}`)
          .fontSize(13)
          .fontColor('#317af7')

        Text(`父组件看到的 user.city = ${this.user.address.city}`)
          .fontSize(13)
          .fontColor('#317af7')

        Row({ space: 10 }) {
          Button('父 +10').onClick(() => {
            this.total += 10
          })
          Button('父 seed +10').onClick(() => {
            this.seedFromParent += 10
          })
        }

        Ch47ParamCard({
          title: '子卡片：四个装饰器一起看',
          value: this.total,
          seed: this.seedFromParent,
          user: this.user,
          onAdd: (delta: number) => {
            this.total += delta
          }
        })

        Column({ space: 6 }) {
          Text('逐条对照').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#C62828')
          Text('1. 点「父 +10」：@Param value 跟着变；@Param @Once seed 纹丝不动 —— 它只认第一次的值。')
            .fontSize(11).fontColor('#555').width('100%')
          Text('2. 点「seed 本地 +1」：@Once 允许子组件自己改，且不会回传给父。V1 里想做这件事只能拆一个 @State 再手动同步。')
            .fontSize(11).fontColor('#555').width('100%')
          Text('3. 点「通知父 +1」：子组件改不了 @Param，只能通过 @Event 请父组件改。V1 的 @Link 是双向的，谁都能改，出问题时很难查。')
            .fontSize(11).fontColor('#555').width('100%')
          Text('4. 点「直接改 user.city」：@Param 传对象是引用传递，改字段两边都能看到。V1 的 @Prop 传对象是深拷贝，子组件改完父组件毫无感知。')
            .fontSize(11).fontColor('#555').width('100%')
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
