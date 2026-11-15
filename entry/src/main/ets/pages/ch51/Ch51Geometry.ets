// Chapter 51 §A: geometryTransition — the "one continuous shot" expand.
//
// ch20 used sharedTransition(), which only pairs components across two router
// pages. geometryTransition(id) pairs by id INSIDE one page: put the same id on
// a thumbnail and a fullscreen viewer, switch between them with if/else, and the
// framework flies position+size between the two while the old branch unmounts.
//
// Rules learned the hard way (kept in code so the article can cite them):
//  1. The state flip MUST be wrapped in animateTo (or have .animation() attached)
//     — flip the boolean bare and both views just hard-swap, no flight.
//  2. Only ONE component with a given id may exist at a time — the if/else
//     guarantees that (one branch is unmounting while the other mounts).
//  3. Add TransitionEffect.OPACITY on both: without it the incoming branch
//     pops in at full opacity before the geometry animation finishes.
import { curves } from '@kit.ArkUI'

interface PhotoItem {
  id: number
  color: string
  title: string
}

@Entry
@Component
struct Ch51GeometryPage {
  @State expandedId: number = -1
  @State flightCount: number = 0
  private photos: PhotoItem[] = [
    { id: 0, color: '#FF7043', title: '晚霞' },
    { id: 1, color: '#42A5F5', title: '海面' },
    { id: 2, color: '#66BB6A', title: '草地' },
    { id: 3, color: '#AB47BC', title: '花田' },
    { id: 4, color: '#FFB300', title: '沙漠' },
    { id: 5, color: '#26C6DA', title: '冰川' }
  ]

  private photoOf(id: number): PhotoItem {
    for (const p of this.photos) {
      if (p.id === id) {
        return p
      }
    }
    return this.photos[0]
  }

  // Both the flip and the count bump live inside ONE animateTo closure —
  // everything inside animates together in a single transaction.
  private toggle(id: number): void {
    this.getUIContext()?.animateTo(
      { duration: 450, curve: curves.cubicBezierCurve(0.33, 0, 0.15, 1) },
      () => {
        this.expandedId = this.expandedId === id ? -1 : id
        this.flightCount++
      }
    )
  }

  // The fullscreen branch. Same geometryTransition id as the thumbnail = pair.
  @Builder
  fullView(p: PhotoItem) {
    Column({ space: 16 }) {
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#fff')
          .padding(12)
          .onClick(() => this.toggle(p.id))
      }
      .width('100%')

      Column()
        .width('88%')
        .aspectRatio(0.75)
        .borderRadius(16)
        .backgroundColor(p.color)
        .geometryTransition('photo_' + p.id, { follow: true } as GeometryTransitionOptions)
        .transition(TransitionEffect.OPACITY)

      Text(`${p.title} · 全屏查看 · 已飞行 ${this.flightCount} 次`)
        .fontSize(14)
        .fontColor('#eee')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1a1a1a')
    .transition(TransitionEffect.OPACITY)
  }

  build() {
    Stack() {
      if (this.expandedId < 0) {
        Column({ space: 12 }) {
          Text('A · geometryTransition 一镜到底')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20 })

          Text('缩略图和全屏视图共用一个 geometryTransition id，用 if/else 切换分支。点任意卡片——它不是"跳页"，是原地长成全屏。')
            .fontSize(13)
            .fontColor('#666')
            .width('92%')

          Grid() {
            ForEach(this.photos, (p: PhotoItem) => {
              GridItem() {
                Column({ space: 6 }) {
                  Column()
                    .width('100%')
                    .aspectRatio(0.75)
                    .borderRadius(12)
                    .backgroundColor(p.color)
                    .geometryTransition('photo_' + p.id, { follow: true } as GeometryTransitionOptions)
                    .transition(TransitionEffect.OPACITY)
                    .onClick(() => this.toggle(p.id))

                  Text(p.title)
                    .fontSize(12)
                    .fontColor('#666')
                }
              }
            }, (p: PhotoItem) => 'ph_' + p.id.toString())
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .height(420)

          Text('对比 ch20 的 sharedTransition：那个要开两个页面才能飞；这个同页 if/else 就配对，连 router 都不用。')
            .fontSize(12)
            .fontColor('#888')
            .width('92%')
        }
        .width('100%')
        .height('100%')
      } else {
        this.fullView(this.photoOf(this.expandedId))
      }
    }
    .width('100%')
    .height('100%')
  }
}
