// Chapter 15 §三: Observing built-in types (Array / Map / Set / Date).
// They cannot be decorated directly with @Observed; instead extend the type
// and decorate the subclass. Below we observe a custom Array of numbers.

@Observed
class MyArray extends Array<number> {
}

@Entry
@Component
struct MapDemo {
  // @State wraps the container so the first layer + common APIs are observed.
  @State list: MyArray = new MyArray()

  aboutToAppear(): void {
    this.list.push(1)
    this.list.push(2)
    this.list.push(3)
  }

  build() {
    Column({ space: 16 }) {
      Text('@Observed extends Array 示例')
        .fontSize(20)
        .margin(16)

      Button('追加一个数字')
        .onClick(() => {
          this.list.push(this.list.length + 1)
        })

      List({ space: 8 }) {
        // Iterate with index; key uses the index string for this demo.
        ForEach(this.list, (item: number, index: number) => {
          ListItem() {
            Text(`${index}: ${item}`)
              .fontSize(18)
              .padding(12)
              .width('100%')
          }
        }, (item: number, index: number) => index.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
  }
}
