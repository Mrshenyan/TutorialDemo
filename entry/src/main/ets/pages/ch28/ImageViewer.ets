import { router } from '@kit.ArkUI';

// Chapter 28 §1: image viewer that combines pan + pinch + rotate.
// All three gestures live in ONE GestureGroup(Parallel, ...) so they are
// recognized at the same time (e.g. two fingers can zoom AND rotate together).
//
// Accumulation rule (the key to "continuous" transforms):
//   GestureEvent.scale / .angle / .offsetX are RELATIVE to the gesture START.
//   - scale starts at 1.0, angle starts at 0, offset starts at 0.
//   - So we snapshot the CURRENT value in onActionStart, then in onActionUpdate
//     we compute  value = snapshot + relativeDelta  (or snapshot * scale).
//   Without this, every new gesture would snap back to 1.0 / 0.
@Entry
@Component
struct Ch28ImageViewer {
  @State scaleValue: number = 1;
  @State angle: number = 0;
  @State offsetX: number = 0;
  @State offsetY: number = 0;

  private startScale: number = 1;
  private startAngle: number = 0;
  private startX: number = 0;
  private startY: number = 0;

  // keep the transform inside a reasonable range
  private clampScale(v: number): number {
    return Math.min(3, Math.max(0.5, v));
  }

  build() {
    Column({ space: 14 }) {
      Text('可缩放 / 旋转 / 拖拽的图片查看器')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Text('双指捏合缩放 · 双指旋转 · 单指拖拽；下方按钮可复位 / 放大 / 缩小')
        .fontSize(13)
        .fontColor('#666')
        .padding({ left: 12, right: 12 })

      Column() {
        Image($r('app.media.startIcon'))
          .width(220)
          .height(220)
          .scale({ x: this.scaleValue, y: this.scaleValue })
          .rotate({ angle: this.angle })
          .translate({ x: this.offsetX, y: this.offsetY })
      }
      .width('90%')
      .layoutWeight(1)
      .backgroundColor('#F2F4F7')
      .borderRadius(12)
      .gesture(
        // Parallel: pan / pinch / rotate are recognized simultaneously.
        GestureGroup(GestureMode.Parallel,
          // single-finger pan: accumulate offset from the gesture start
          PanGesture({ fingers: 1 })
            .onActionStart((event: GestureEvent) => {
              this.startX = this.offsetX;
              this.startY = this.offsetY;
            })
            .onActionUpdate((event: GestureEvent) => {
              this.offsetX = this.startX + event.offsetX;
              this.offsetY = this.startY + event.offsetY;
            }),
          // two-finger pinch: scale is relative to 1.0 at the gesture start
          PinchGesture({ fingers: 2 })
            .onActionStart((event: GestureEvent) => {
              this.startScale = this.scaleValue;
            })
            .onActionUpdate((event: GestureEvent) => {
              this.scaleValue = this.clampScale(this.startScale * event.scale);
            }),
          // two-finger rotation: angle is relative to 0 at the gesture start
          RotationGesture({ fingers: 2 })
            .onActionStart((event: GestureEvent) => {
              this.startAngle = this.angle;
            })
            .onActionUpdate((event: GestureEvent) => {
              this.angle = this.startAngle + event.angle;
            })
        )
      )

      Text(`缩放 ${this.scaleValue.toFixed(2)}× | 旋转 ${this.angle.toFixed(0)}° | 位移 (${this.offsetX.toFixed(0)}, ${this.offsetY.toFixed(0)})`)
        .fontSize(12)
        .fontColor('#888')

      Row({ space: 12 }) {
        Button('复位')
          .layoutWeight(1)
          .backgroundColor('#9E9E9E')
          .onClick(() => {
            this.scaleValue = 1;
            this.angle = 0;
            this.offsetX = 0;
            this.offsetY = 0;
          })
        Button('放大')
          .layoutWeight(1)
          .backgroundColor('#1E88E5')
          .onClick(() => { this.scaleValue = this.clampScale(this.scaleValue + 0.2); })
        Button('缩小')
          .layoutWeight(1)
          .backgroundColor('#43A047')
          .onClick(() => { this.scaleValue = this.clampScale(this.scaleValue - 0.2); })
      }
      .width('90%')

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
