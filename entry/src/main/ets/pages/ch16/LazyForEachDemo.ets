// Chapter 16 §五: a minimal IDataSource + LazyForEach.
// LazyForEach watches a DataSource + change notifications, not a plain array.

class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = []
  private dataArray: string[] = []

  public totalCount(): number {
    return this.dataArray.length
  }

  public getData(index: number): string {
    return this.dataArray[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  pushData(data: string): void {
    this.dataArray.push(data)
    this.notifyDataAdd(this.dataArray.length - 1)
  }
}

@Entry
@Component
struct LazyListPage {
  private data: BasicDataSource = new BasicDataSource()

  aboutToAppear(): void {
    for (let i = 0; i < 30; i++) {
      this.data.pushData(`Hello ${i}`)
    }
  }

  build() {
    Column({ space: 12 }) {
      Button('末尾再加一条')
        .margin(12)
        .onClick(() => {
          this.data.pushData(`Hello ${this.data.totalCount()}`)
        })

      List({ space: 6 }) {
        LazyForEach(this.data, (item: string) => {
          ListItem() {
            Text(item)
              .fontSize(20)
              .width('100%')
              .padding(12)
          }
        }, (item: string) => item)
      }
      .cachedCount(5) // preload a few items outside the viewport
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
