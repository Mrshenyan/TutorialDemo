// Chapter 49: one IDataSource that can also mutate its contents.
//
// LazyForEach only ever asks for totalCount() and getData(i). Everything else
// in this file exists so the tuning page can delete / rename rows and tell the
// list about it through the listener it registered.
import { FeedItem } from './Ch49Models'

export class FeedDataSource implements IDataSource {
  private listeners: DataChangeListener[] = []
  private items: FeedItem[] = []

  constructor(items: FeedItem[]) {
    this.items = items
  }

  totalCount(): number {
    return this.items.length
  }

  getData(index: number): FeedItem {
    return this.items[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos: number = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataChange(index)
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataAdd(index)
    })
  }

  notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded()
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataDelete(index)
    })
  }

  insertAt(index: number, item: FeedItem): void {
    this.items.splice(index, 0, item)
    this.notifyDataAdd(index)
  }

  reset(items: FeedItem[]): void {
    this.items = items
    this.notifyDataReload()
  }

  removeAt(index: number): void {
    if (index < 0 || index >= this.items.length) {
      return
    }
    this.items.splice(index, 1)
    this.notifyDataDelete(index)
  }

  renameAt(index: number, title: string): void {
    if (index < 0 || index >= this.items.length) {
      return
    }
    this.items[index].title = title
    this.notifyDataChange(index)
  }

  // Write-through used by the "restore on reuse" page: the row keeps its own
  // @State for the UI, and this keeps the real value on the data model.
  // Deliberately silent — the row has already repainted itself.
  setLikedById(id: number, liked: boolean): void {
    for (let i = 0; i < this.items.length; i++) {
      if (this.items[i].id === id) {
        this.items[i].liked = liked
        return
      }
    }
  }
}
