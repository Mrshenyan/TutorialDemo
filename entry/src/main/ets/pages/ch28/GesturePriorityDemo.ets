import { router } from '@kit.ArkUI';

// Chapter 28 §2: gesture priority between a parent and a child.
// Three binding methods decide WHO wins when the same gesture happens in
// both a parent and a child:
//   - .gesture(g)         : normal binding. CHILD wins over the parent's normal gesture.
//   - .priorityGesture(g) : parent wins; recognized BEFORE child gestures and, with the
//                           default GestureMask.NORMAL, BLOCKS the child gesture entirely.
//   - .parallelGesture(g) : parent and child BOTH respond (recognized in parallel).
// This demo uses .priorityGesture on the parent: tapping the blue child box
// increments the PARENT counter, and the child's own .gesture Tap is blocked.
// Switch the parent to .gesture(...) (see comment) to let the child win instead.
@Entry
@Component
struct Ch28GesturePriority {
  @State parentTap: number = 0;
  @State childTap: number = 0;

  build() {
    Column({ space: 16 }) {
      Text('手势优先级：父容器 vs 子视图（同一区域都绑 Tap）')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })
        .padding({ left: 12, right: 12 })

      Text(`父容器 Tap 次数：${this.parentTap}    子视图 Tap 次数：${this.childTap}`)
        .fontSize(15)

      // PARENT container. It binds a Tap with HIGH priority.
      Column() {
        Text('我是父容器（橙色区域）')
          .fontSize(13)
          .fontColor('#666')
          .margin({ bottom: 10 })

        // CHILD box. Its own normal .gesture Tap is the default-locally-wins one.
        Column() {
          Text('我是子视图（蓝色）')
            .fontSize(15)
            .fontColor('#0D47A1')
        }
        .padding(24)
        .backgroundColor('#BBDEFB')
        .borderRadius(8)
        .gesture(
          TapGesture({ count: 1 })
            .onAction(() => {
              this.childTap++;
            })
        )
      }
      .padding(30)
      .backgroundColor('#FFE0B2')
      .borderRadius(12)
      // Parent uses priorityGesture -> parent wins, child Tap is blocked.
      .gesture(
        TapGesture({ count: 1 })
          .onAction(() => {
            this.parentTap++;
          })
      )
      // To let the CHILD win instead, comment the .priorityGesture above and
      // uncomment the line below:
      // .gesture(TapGesture({ count: 1 }).onAction(() => { this.parentTap++; }))

      Text('当前：父容器用 .priorityGesture，点蓝色子视图 → 只计父容器次数。把父容器改成 .gesture 再试，子视图会赢。')
        .fontSize(13)
        .fontColor('#888')
        .padding({ left: 16, right: 16 })

      Button('重置计数')
        .width('80%')
        .backgroundColor('#9E9E9E')
        .onClick(() => {
          this.parentTap = 0;
          this.childTap = 0;
        })

      Button('返回')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
