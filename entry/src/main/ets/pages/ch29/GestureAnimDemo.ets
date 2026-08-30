import { router, curves } from '@kit.ArkUI';

// Chapter 29 §一: link GESTURES to EXPLICIT animation (animateTo).
//
// Core idea — two phases with two different techniques:
//   1) While the finger is moving, we set @State DIRECTLY in onActionUpdate,
//      so the image follows the finger 1:1 (no animation, instant).
//   2) When the gesture ends (onActionEnd) or on a tap, we wrap the state
//      change in getUIContext().animateTo(...), so the change becomes a smooth tween.
//
// This is the canonical "手势 + 动画联动" pattern:
//   gesture drives the number, animateTo drives the transition between numbers.
@Entry
@Component
struct Ch29GestureAnim {
  @State scaleValue: number = 1;
  @State angle: number = 0;
  @State offsetX: number = 0;
  @State offsetY: number = 0;

  private startScale: number = 1;
  private startAngle: number = 0;
  private startX: number = 0;
  private startY: number = 0;

  // Keep the transform inside a reasonable range.
  private clampScale(v: number): number {
    return Math.min(3, Math.max(0.5, v));
  }

  // Max allowed free drag offset; beyond this we spring back on release.
  private maxOffset: number = 120;

  build() {
    Column({ space: 14 }) {
      Text('手势 + 动画联动（图片查看器升级版）')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Text('拖拽跟手 · 松手回弹 · 双击平滑放大 · 按钮复位带动画')
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
          // Double-tap: smooth zoom via explicit animation.
          .gesture(
            TapGesture({ count: 2 })
              .onAction(() => {
                this.getUIContext()?.animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
                  this.scaleValue = this.scaleValue > 1.5 ? 1 : 2;
                })
              })
          )
      }
      .width('90%')
      .layoutWeight(1)
      .backgroundColor('#F2F4F7')
      .borderRadius(12)
      .gesture(
        // Parallel: pan / pinch / rotate recognized at the same time.
        GestureGroup(GestureMode.Parallel,
          // ① Single-finger pan: follow the finger INSTANTLY (no animation).
          PanGesture({ fingers: 1 })
            .onActionStart((event: GestureEvent) => {
              this.startX = this.offsetX;
              this.startY = this.offsetY;
            })
            .onActionUpdate((event: GestureEvent) => {
              // WHY no animation here: gesture events arrive every VSync frame
              // (~16ms @60Hz). If translate had .animation() attached, each
              // per-frame state change would start a fresh tween and the view
              // would permanently lag behind the finger ("肉"). During drag we
              // set @State INSTANTLY so the component follows 1:1; the smooth
              // transition only happens in onActionEnd via getUIContext().animateTo.
              this.offsetX = this.startX + event.offsetX;
              this.offsetY = this.startY + event.offsetY;
            })
            // ② On release: if dragged out of bounds, SPRING BACK with animation.
            .onActionEnd(() => {
              const targetX = Math.min(this.maxOffset, Math.max(-this.maxOffset, this.offsetX));
              const targetY = Math.min(this.maxOffset, Math.max(-this.maxOffset, this.offsetY));
              if (targetX !== this.offsetX || targetY !== this.offsetY) {
                this.getUIContext()?.animateTo({ duration: 320, curve: curves.springCurve(0, 1, 228, 30) }, () => {
                  this.offsetX = targetX;
                  this.offsetY = targetY;
                })
              }
            }),
          // Two-finger pinch: scale is relative to 1.0 at the gesture start.
          PinchGesture({ fingers: 2 })
            .onActionStart((event: GestureEvent) => {
              this.startScale = this.scaleValue;
            })
            .onActionUpdate((event: GestureEvent) => {
              this.scaleValue = this.clampScale(this.startScale * event.scale);
            }),
          // Two-finger rotation: angle is relative to 0 at the gesture start.
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
        Button('复位(带动画)')
          .layoutWeight(1)
          .backgroundColor('#9E9E9E')
          .onClick(() => {
            this.getUIContext()?.animateTo({ duration: 360, curve: Curve.EaseInOut }, () => {
              this.scaleValue = 1;
              this.angle = 0;
              this.offsetX = 0;
              this.offsetY = 0;
            })
          })
        Button('放大')
          .layoutWeight(1)
          .backgroundColor('#1E88E5')
          .onClick(() => {
            this.getUIContext()?.animateTo({ duration: 240, curve: Curve.EaseOut }, () => {
              this.scaleValue = this.clampScale(this.scaleValue + 0.3);
            })
          })
        Button('缩小')
          .layoutWeight(1)
          .backgroundColor('#43A047')
          .onClick(() => {
            this.getUIContext()?.animateTo({ duration: 240, curve: Curve.EaseOut }, () => {
              this.scaleValue = this.clampScale(this.scaleValue - 0.3);
            })
          })
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
