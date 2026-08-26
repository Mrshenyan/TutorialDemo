import { router } from '@kit.ArkUI';

// Chapter 28 §3: the three GestureMode values of GestureGroup.
//   - Sequence  : gestures recognized IN ORDER; the next gesture only starts
//                 after the previous one succeeds (classic "long-press then drag").
//   - Parallel  : all gestures recognized at the SAME TIME, independently.
//   - Exclusive : all recognized at the same time, but if ONE succeeds the
//                 others immediately fail (only a single winner).
@Entry
@Component
struct Ch28CombinedModes {
  // Sequence's first gesture is a repeat long-press: while the finger is held
  // down, onAction fires again and again (event.repeat === true), so this
  // counter keeps climbing during the hold/drag. It counts REPEAT TICKS,
  // NOT "how many long-press sequences you completed".
  @State seqRepeatTicks: number = 0;
  // A full sequence (long-press succeeded -> drag begins) only triggers once
  // per drag, so this counts actual completed sequences.
  @State seqDone: number = 0;
  @State seqOffsetX: number = 0;
  @State seqOffsetY: number = 0;
  // Parallel: single tap and double tap both count (both fire).
  @State parTap1: number = 0;
  @State parTap2: number = 0;
  // Exclusive: only ONE of tap / long-press wins (they never both fire).
  @State excTap: number = 0;
  @State excLongPress: number = 0;
  private seqStartX: number = 0;
  private seqStartY: number = 0;

  build() {
    Column({ space: 14 }) {
      Text('组合手势三兄弟：Sequence / Parallel / Exclusive')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })
        .padding({ left: 12, right: 12 })

      // 1) Sequence: long-press first, then drag
      Column() {
        Text(`① Sequence（先长按再拖动） 长按持续帧:${this.seqRepeatTicks}  完成序列:${this.seqDone}`)
          .fontSize(13)
          .fontColor('#666')
        Text('按住我拖动')
          .fontSize(16)
          .fontColor(Color.White)
          .padding(18)
          .backgroundColor('#1E88E5')
          .borderRadius(8)
          .translate({ x: this.seqOffsetX, y: this.seqOffsetY })
          .gesture(
            GestureGroup(GestureMode.Sequence,
              LongPressGesture({ repeat: true })
                .onAction((event: GestureEvent) => {
                  // repeat:true => while the finger is held, onAction fires
                  // again and again. event.repeat is true on every re-fire,
                  // so this counter keeps climbing during the hold/drag.
                  // It counts REPEAT TICKS, not "how many long-presses you did".
                  if (event.repeat) {
                    this.seqRepeatTicks++;
                  }
                }),
              PanGesture({ fingers: 1 })
                .onActionStart(() => {
                  // A full long-press succeeded and the drag just began:
                  // this fires exactly once per sequence.
                  this.seqDone++;
                  this.seqStartX = this.seqOffsetX;
                  this.seqStartY = this.seqOffsetY;
                })
                .onActionUpdate((event: GestureEvent) => {
                  this.seqOffsetX = this.seqStartX + event.offsetX;
                  this.seqOffsetY = this.seqStartY + event.offsetY;
                })
            )
          )
      }
      .padding(12)
      .align(Alignment.TopStart)
      .backgroundColor('#E3F2FD')
      .borderRadius(12)
      .width('92%')

      // 2) Parallel: single tap and double tap both count
      Column() {
        Text(`② Parallel（单击 + 双击并行） 单击:${this.parTap1}  双击:${this.parTap2}`)
          .fontSize(13)
          .fontColor('#666')
        Text('点我')
          .fontSize(16)
          .padding(18)
          .backgroundColor('#43A047')
          .fontColor(Color.White)
          .borderRadius(8)
          .gesture(
            GestureGroup(GestureMode.Parallel,
              TapGesture({ count: 1 })
                .onAction(() => { this.parTap1++; }),
              TapGesture({ count: 2 })
                .onAction(() => { this.parTap2++; })
            )
          )
      }
      .padding(12)
      .backgroundColor('#E8F5E9')
      .borderRadius(12)
      .width('92%')

      // 3) Exclusive: only one of TAP / LONG-PRESS wins.
      //    NOTE: do NOT demo Exclusive with two TapGestures (count:1 + count:2).
      //    A count:1 tap is recognized on the very first tap, so the count:2
      //    double-tap can never accumulate -> single/double cannot be told apart.
      //    Use two gestures of different NATURE (tap vs long-press) instead.
      Column() {
        Text(`③ Exclusive（轻点 / 长按互斥） 轻点:${this.excTap}  长按:${this.excLongPress}`)
          .fontSize(13)
          .fontColor('#666')
        Text('轻点我 / 长按我')
          .fontSize(16)
          .padding(18)
          .backgroundColor('#E53935')
          .fontColor(Color.White)
          .borderRadius(8)
          .gesture(
            GestureGroup(GestureMode.Exclusive,
              TapGesture({ count: 1 })
                .onAction(() => { this.excTap++; }),
              LongPressGesture({ repeat: false })
                .onAction(() => { this.excLongPress++; })
            )
          )
      }
      .padding(12)
      .backgroundColor('#FFEBEE')
      .borderRadius(12)
      .width('92%')

      Button('返回')
        .width('80%')
        .margin({ top: 4 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
