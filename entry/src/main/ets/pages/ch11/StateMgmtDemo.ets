// Chapter 11 demo: the difference between a @State variable and a regular variable.
@Entry
@Component
struct StateMgmtDemo {
  @State count: number = 0
  private increaseBy: number = 1 // regular variable, NOT observed by the framework

  build() {
    Column({ space: 14 }) {
      Text(`count（@State 状态变量）: ${this.count}`)
        .fontSize(18)

      Text(`increaseBy（普通变量，改动不会自动刷新本行）: ${this.increaseBy}`)
        .fontSize(14)
        .fontColor('#666')

      Button('count += increaseBy')
        .onClick(() => {
          this.count += this.increaseBy
        })

      Button('increaseBy++（普通变量）')
        .onClick(() => {
          this.increaseBy += 1
        })

      Text('说明：点“increaseBy++”本行不变（普通变量不驱动刷新）；点“count+=”整页重渲染，两行一起更新。')
        .fontSize(12)
        .fontColor('#999')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Center)
  }
}
