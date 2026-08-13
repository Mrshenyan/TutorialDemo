import { router } from '@kit.ArkUI'

// Snapshot template demo: an ArkTS heap leak held by a module-level (static) array.
// Take two ArkTS heap snapshots in Profiler and Diff: a positive Size Delta means leaked
// objects. GOOD ("fix"): clear the array so references are released. Material §4.6.

// module-level holder = the classic leak root (material §4.6: 静态变量/全局引用持有)
let ch23LeakHolder: object[] = []

class Ch23LeakedObj {
  id: number = 0
  payload: number[] = []
  constructor(id: number) {
    this.id = id
    // allocate some payload so the object is non-trivial in the heap
    for (let i = 0; i < 10000; i++) {
      this.payload.push(i)
    }
  }
}

@Entry
@Component
struct Ch23Snapshot {
  @State count: number = 0

  // BAD: every tap pushes a new object into the static array -> ArkTS heap grows.
  leakOnce(): void {
    ch23LeakHolder.push(new Ch23LeakedObj(this.count))
    this.count += 1
  }

  // GOOD: clear the static reference -> objects become GC-eligible.
  fixLeak(): void {
    ch23LeakHolder = []
    this.count = 0
  }

  build() {
    Column({ space: 16 }) {
      Text('Snapshot · ArkTS 堆快照/泄漏')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24 })

      Text('反复点「泄漏对象」，在 Profiler Snapshot 模板拍两次快照 Diff，Size Delta 为正即泄漏')
        .fontSize(13)
        .fontColor('#666')
        .margin({ bottom: 8 })

      Text(`已泄漏对象: ${this.count}`).fontSize(16)

      Button('泄漏对象（推入静态数组）').width('90%')
        .onClick(() => this.leakOnce())
      Button('修复：清空静态引用').width('90%')
        .onClick(() => this.fixLeak())

      Text('定位技巧：快照 Diff 后查 References，找异常持有（静态变量 / 全局定时器）')
        .fontSize(12)
        .fontColor('#999')

      Button('返回').width('90%').margin({ top: 8 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
