// Chapter 48 §三: inside a @Sendable class you must use collections.Map,
// and you cannot iterate it with for...of in .ets files.
import { taskpool } from '@kit.ArkTS'
import { SharedInventory } from '../ch48data/Ch48Models'
import { fillInventory } from '../ch48data/Ch48Tasks'

@Entry
@ComponentV2
struct Ch48CollectionsPage {
  private inv: SharedInventory = new SharedInventory()
  @Local appleCount: number = 0
  @Local returned: number = 0
  @Local rows: string[] = []

  async runFill(): Promise<void> {
    const r: number = await taskpool.execute(fillInventory, this.inv, '苹果', 100) as number
    this.returned = r
    this.appleCount = this.inv.items.get('苹果') ?? 0
  }

  // collections.Map has no usable Symbol.iterator in .ets files, so for...of is
  // out. forEach is the portable way to walk it.
  showAll(): void {
    const out: string[] = []
    this.inv.items.forEach((value: number, key: string) => {
      out.push(`${key} × ${value}`)
    })
    this.rows = out
  }

  addBanana(): void {
    this.inv.add('香蕉', 5)
    this.showAll()
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('Sendable 容器：collections.Map')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })

        Text('@Sendable 类的字段只能是 number / string / boolean / 其他 Sendable 对象 / collections 容器。普通 Map 塞进去编译就过不了，得换成 collections.Map。')
          .fontSize(12)
          .fontColor('#888')
          .width('92%')

        Column({ space: 8 }) {
          Text(`苹果库存（主线程读到的）= ${this.appleCount}`).fontSize(15).fontColor('#2E7D32')
          Text(`子线程 return 值 = ${this.returned}`).fontSize(15).fontColor('#B71C1C')
          Row({ space: 10 }) {
            Button('子线程加 100 个苹果').onClick(() => {
              this.runFill()
            })
          }
          Row({ space: 10 }) {
            Button('主线程加 5 个香蕉').onClick(() => {
              this.addBanana()
            })
            Button('清点库存').onClick(() => {
              this.showAll()
            })
          }
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#E3F2FD')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('库存清单').fontSize(14).fontWeight(FontWeight.Medium)
          ForEach(this.rows, (row: string) => {
            Text(row).fontSize(12).fontColor('#555').width('100%')
          }, (row: string) => row)
          if (this.rows.length === 0) {
            Text('点「清点库存」看看').fontSize(11).fontColor('#999')
          }
        }
        .width('92%')
        .padding(12)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('两个坑').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#C62828')
          Text('1. @Sendable 类里写 Map<string, number> 会报类型错误，必须 collections.Map。')
            .fontSize(11).fontColor('#555').width('100%')
          Text('2. collections.Map 的 Symbol.iterator 在 .ets 文件里不可用，for (const [k, v] of map) 直接不认，改用 forEach。')
            .fontSize(11).fontColor('#555').width('100%')
          Text('注意子线程加完 100 个，主线程这边读到的也是 100 —— 共享内存，同一个 Map。')
            .fontSize(11).fontColor('#2E7D32').width('100%')
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
