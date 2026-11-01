// Chapter 47 §五: @Provider / @Consumer -- cross-layer plumbing without
// threading props through every level. Alias matching keeps the names readable.
//
// Middle layer deliberately does nothing: it neither receives nor forwards the
// theme, which is the whole point of this pair.

@ComponentV2
struct Ch47Leaf {
  // Matched by alias, not by variable name.
  @Consumer('themeColor') theme: string = '#317af7'

  build() {
    Column({ space: 6 }) {
      Text('第三层：@Consumer').fontSize(13).fontWeight(FontWeight.Medium)
      Text(`当前主题色：${this.theme}`).fontSize(13).fontColor(this.theme)
      Button('叶子改成橙色').fontSize(11).height(30).onClick(() => {
        // @Provider/@Consumer is still a two-way binding: the leaf can write back.
        this.theme = '#EF6C00'
      })
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#FFFFFF')
    .borderRadius(6)
    .alignItems(HorizontalAlign.Start)
  }
}

@ComponentV2
struct Ch47Middle {
  build() {
    Column({ space: 6 }) {
      Text('第二层：中间层，一行参数都没传').fontSize(13).fontWeight(FontWeight.Medium)
      Ch47Leaf()
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#F5F5F5')
    .borderRadius(6)
    .alignItems(HorizontalAlign.Start)
  }
}

@Entry
@ComponentV2
struct Ch47ProviderConsumerPage {
  // The alias 'themeColor' is what the leaf looks for.
  @Provider('themeColor') theme: string = '#317af7'

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('@Provider / @Consumer')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })

        Text('跨三层传一个值，V1 的写法是每一层都写一遍 @Prop 接力；V2 让提供方和消费方直接对上，中间层可以完全不知情。')
          .fontSize(12)
          .fontColor('#888')
          .width('92%')

        Column({ space: 8 }) {
          Text(`第一层（@Provider）当前值：${this.theme}`)
            .fontSize(13)
            .fontColor(this.theme)

          Row({ space: 10 }) {
            Button('顶层改蓝色').onClick(() => {
              this.theme = '#317af7'
            })
            Button('顶层改绿色').onClick(() => {
              this.theme = '#2E7D32'
            })
          }
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#E3F2FD')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 8 }) {
          Text('下面的第三层能直接读到这个值，也能反过来改它：').fontSize(12).fontColor('#888')
          Ch47Middle()
        }
        .width('92%')

        Column({ space: 6 }) {
          Text('和 V1 的 @Provide / @Consume 差在哪').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#6A1B9A')
          Text('能力上基本对等：都是按「变量名或别名」匹配、都是双向同步。V2 这一对主要是改名并纳入新体系，真正的增量是它能配合 @ObservedV2 —— 传一个被追踪的对象下去，深层属性变化也能穿透几层组件。')
            .fontSize(11)
            .fontColor('#555')
            .width('100%')
          Text('另外提醒：@Provider / @Consumer 双向绑定意味着任何一层都能改。层级一多，改动来源就难追——能用 @Param + @Event 单向传的地方，优先单向。')
            .fontSize(11)
            .fontColor('#C62828')
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
