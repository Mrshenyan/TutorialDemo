// Chapter 16 §一-§二: ForEach basics + the importance of a stable key.
// Use a business-unique id as the key generator, never the array index.

@Observed
class Fruit {
  id: string
  name: string

  constructor(id: string, name: string) {
    this.id = id
    this.name = name
  }
}

@Entry
@Component
struct ForEachDemo {
  @State fruits: Fruit[] = [
    new Fruit('f1', '苹果'),
    new Fruit('f2', '香蕉'),
    new Fruit('f3', '葡萄')
  ]

  build() {
    Column({ space: 12 }) {
      Button('再加一个西瓜')
        .margin(12)
        .onClick(() => {
          const id = 'f' + (this.fruits.length + 1)
          this.fruits.push(new Fruit(id, '西瓜'))
        })

      List({ space: 8 }) {
        ForEach(this.fruits, (item: Fruit) => {
          ListItem() {
            Text(item.name)
              .fontSize(18)
              .padding(12)
              .width('100%')
          }
        }, (item: Fruit) => item.id) // stable, unique business id
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
