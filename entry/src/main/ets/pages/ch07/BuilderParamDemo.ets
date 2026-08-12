// Chapter 7 demo: @BuilderParam passes a builder function into a child component.
@Builder function globalOverBuilder() {
  Text('global builder content').fontSize(16)
}

@Entry
@Component
struct BuilderParamDemo {
  @State text: string = 'header'

  // A builder defined in the parent component.
  @Builder parentBuilder() {
    Text(`Parent builder -> ${this.text}`).fontSize(18)
  }

  build() {
    Column({ space: 16 }) {
      // 1) Pass a parent's member builder into the child's @BuilderParam.
      ChildA({ customBuilderParam: this.parentBuilder })

      // 2) Trailing closure: the {} after CustomContainer is treated as its @BuilderParam.
      CustomContainer({ header: this.text }) {
        Column({ space: 6 }) {
          Text('尾随闭包内容 A').fontSize(16)
          Text('尾随闭包内容 B').fontSize(16)
        }
        .backgroundColor(Color.Yellow)
        .onClick(() => {
          this.text = 'changeHeader'
        })
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}

@Component
struct ChildA {
  // Initialized by the parent's builder; falls back to the global one.
  @BuilderParam customBuilderParam: () => void = globalOverBuilder

  build() {
    Column({ space: 4 }) {
      Text('ChildA:').fontSize(14).fontColor('#666')
      this.customBuilderParam()
    }
    .alignItems(HorizontalAlign.Start)
    .padding(10)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }
}

@Component
struct CustomContainer {
  @Prop header: string = ''
  @BuilderParam closer: () => void = globalOverBuilder

  build() {
    Column({ space: 6 }) {
      Text(this.header).fontSize(18)
      this.closer()
    }
    .alignItems(HorizontalAlign.Start)
    .padding(10)
    .backgroundColor('#EAF2FF')
    .borderRadius(8)
  }
}
