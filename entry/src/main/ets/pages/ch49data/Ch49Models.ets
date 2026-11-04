// Chapter 49 data models and the shared counters.
//
// The counters are deliberately plain static fields, not @State: they are
// written from inside component lifecycles, and a static field that is also
// observable would be a global reactive variable — bad idea. Pages mirror them
// into local @State on a timer instead.

export class FeedItem {
  id: number = 0
  index: number = 0
  title: string = ''
  subtitle: string = ''
  hue: string = '#317af7'
  tone: string = '#E3F2FD'
  liked: boolean = false

  constructor(index: number, title: string, subtitle: string, hue: string, tone: string) {
    this.id = index
    this.index = index
    this.title = title
    this.subtitle = subtitle
    this.hue = hue
    this.tone = tone
  }
}

// Two independent counters for the container experiment on page A.
// Same 300 rows, same @Component: one list is a List, the other is a Column.
export class Ch49ContainerStats {
  static inList: number = 0
  static inColumn: number = 0

  static reset(): void {
    Ch49ContainerStats.inList = 0
    Ch49ContainerStats.inColumn = 0
  }
}

// How many component instances the framework actually built / recycled.
export class Ch49Stats {
  static created: number = 0
  static reused: number = 0
  static recycled: number = 0
  static instanceSeq: number = 0

  // A stable id per component instance, so pages can show which instance is
  // currently painting which row.
  static nextInstanceId(): number {
    Ch49Stats.instanceSeq++
    return Ch49Stats.instanceSeq
  }

  // Ids for rows created at runtime (the insert button on the tuning page).
  // Real ids never collide with the ones baked in by buildFeed().
  static feedIdSeq: number = 10000

  static nextFeedId(): number {
    Ch49Stats.feedIdSeq++
    return Ch49Stats.feedIdSeq
  }

  static reset(): void {
    Ch49Stats.created = 0
    Ch49Stats.reused = 0
    Ch49Stats.recycled = 0
    Ch49Stats.instanceSeq = 0
  }
}

const HUES: string[] = ['#317af7', '#2E7D32', '#EF6C00', '#6A1B9A', '#C62828']
const TONES: string[] = ['#E3F2FD', '#E8F5E9', '#FFF3E0', '#F3E5F5', '#FFEBEE']
const CITIES: string[] = ['杭州', '成都', '深圳', '西安', '南京', '苏州', '武汉', '厦门']
const TOPICS: string[] = ['把 LazyForEach 的缓存调了一圈', '复用的组件居然带出了上一条的点赞', '给列表加了 reuseId 之后不抖了',
  '测了一下午，构造次数终于从 300 降到 8', '原来 @State 复用时不会重新初始化', '把定时器忘了清，滚两下就卡']

export function buildFeed(count: number): FeedItem[] {
  const list: FeedItem[] = []
  for (let i = 0; i < count; i++) {
    const hue: string = HUES[i % HUES.length]
    const tone: string = TONES[i % TONES.length]
    const city: string = CITIES[i % CITIES.length]
    const topic: string = TOPICS[i % TOPICS.length]
    list.push(new FeedItem(i, `${city} · 第 ${i + 1} 条`, topic, hue, tone))
  }
  return list
}
