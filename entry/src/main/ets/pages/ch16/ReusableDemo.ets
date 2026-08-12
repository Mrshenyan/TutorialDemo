// Chapter 16 §七: LazyForEach + @Reusable.
// Reusable reuses the component "shell"; data refresh goes through
// aboutToReuse (reuse does NOT re-run aboutToAppear).

@Observed
class GoodsInfo {
  id: string
  name: string
  price: number

  constructor(id: string, name: string, price: number) {
    this.id = id
    this.name = name
    this.price = price
  }
}

@Reusable
@Component
struct GoodsItem {
  @State name: string = ''
  @State price: number = 0

  // Called when pulled from the reuse pool, before re-attach.
  aboutToReuse(params: Record<string, Object>): void {
    this.name = params.name as string
    this.price = params.price as number
  }

  build() {
    Row() {
      Text(this.name)
      Text(`¥${this.price}`).margin({ left: 12 })
    }
    .width('100%')
    .padding(12)
  }
}

class GoodsDataSource implements IDataSource {
  private listeners: DataChangeListener[] = []
  private dataArray: GoodsInfo[] = []

  public totalCount(): number { return this.dataArray.length }
  public getData(index: number): GoodsInfo { return this.dataArray[index] }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) { this.listeners.push(listener) }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) { this.listeners.splice(pos, 1) }
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => { listener.onDataAdd(index) })
  }

  pushData(data: GoodsInfo): void {
    this.dataArray.push(data)
    this.notifyDataAdd(this.dataArray.length - 1)
  }
}

@Entry
@Component
struct ReusableListPage {
  private data: GoodsDataSource = new GoodsDataSource()

  aboutToAppear() {
    this.data.pushData(new GoodsInfo('g1', '苹果', 9.9))
    this.data.pushData(new GoodsInfo('g2', '香蕉', 5.5))
    this.data.pushData(new GoodsInfo('g3', '葡萄', 12.8))
  }

  build() {
    List() {
      LazyForEach(this.data, (item: GoodsInfo) => {
        ListItem() {
          GoodsItem({ name: item.name, price: item.price })
            .reuseId('goods_card')
        }
      }, (item: GoodsInfo) => item.id)
    }
    .cachedCount(5)
    .width('100%')
    .height('100%')
  }
}
