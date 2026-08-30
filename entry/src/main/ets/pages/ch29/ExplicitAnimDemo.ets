import { router, curves } from '@kit.ArkUI';

// Chapter 29 §三: explicit animation (animateTo) + Curve comparison.
//   - Drag a ball and watch it SPRING BACK on release (gesture -> animateTo).
//   - Compare four easing curves moving the same ball to the same target.
//   - Infinite spinner via animation({ iterations: -1 }).
@Entry
@Component
struct Ch29ExplicitAnim {
  // Draggable ball position.
  @State ballX: number = 0;
  @State ballY: number = 0;
  private startBX: number = 0;
  private startBY: number = 0;

  // Curve-comparison ball position.
  @State curveBallX: number = 0;

  // Infinite spinner angle.
  @State spinAngle: number = 0;
  private timer: number = 0;

  aboutToAppear(): void {
    this.timer = setInterval(() => { this.spinAngle += 30 }, 1000);
  }

  aboutToDisappear(): void {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = 0;
    }
  }

  // Move the comparison ball to the same target with a chosen curve,
  // so the DIFFERENCE between curves is visually obvious.
  private moveWith(curve: Curve): void {
    this.getUIContext()?.animateTo({ duration: 700, curve: curve }, () => {
      this.curveBallX = 160;
    })
  }

  build() {
    Column({ space: 18 }) {
      Text('显式动画 animateTo 与曲线')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      // ① Drag + spring back (gesture drives explicit animation).
      Text('① 拖我，松手回弹（curves.springCurve）')
        .fontSize(13)
        .fontColor('#666')
        .alignSelf(ItemAlign.Start)
        .padding({ left: 16 })

      Column() {
        Circle({ width: 48, height: 48 })
          .fill(Color.Blue)
          .translate({ x: this.ballX, y: this.ballY })
      }
      .width('90%')
      .height(150)
      .backgroundColor('#F2F4F7')
      .borderRadius(12)
      .gesture(
        PanGesture({ fingers: 1 })
          .onActionStart((event: GestureEvent) => {
            this.startBX = this.ballX;
            this.startBY = this.ballY;
          })
          .onActionUpdate((event: GestureEvent) => {
            this.ballX = this.startBX + event.offsetX;
            this.ballY = this.startBY + event.offsetY;
          })
          .onActionEnd(() => {
            this.getUIContext()?.animateTo({ duration: 420, curve: curves.springCurve(0, 1, 228, 30) }, () => {
              this.ballX = 0;
              this.ballY = 0;
            })
          })
      )

      // ② Curve comparison.
      Text('② 同一起点 / 同一目标，切换曲线看差异')
        .fontSize(13)
        .fontColor('#666')
        .alignSelf(ItemAlign.Start)
        .padding({ left: 16 })

      Column() {
        Circle({ width: 40, height: 40 })
          .fill(Color.Orange)
          .translate({ x: this.curveBallX })
      }
      .width('90%')
      .height(60)
      .backgroundColor('#F2F4F7')
      .borderRadius(12)

      Scroll(){
        Row(){
          Button('Linear').onClick(() => this.moveWith(Curve.Linear))
          Button('Ease').onClick(() => this.moveWith(Curve.Ease))
          Button('Spring').onClick(() => {
            this.getUIContext()?.animateTo({ duration: 700, curve: curves.springCurve(0, 1, 228, 30) }, () => {
              this.curveBallX = 160;
            })
          })
          Button('EaseInOut').onClick(() => this.moveWith(Curve.EaseInOut))
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('90%')

      Button('归位')
        .width('50%')
        .backgroundColor('#9E9E9E')
        .onClick(() => {
          this.getUIContext()?.animateTo({ duration: 400, curve: Curve.EaseInOut }, () => {
            this.curveBallX = 0;
          })
        })

      // ③ Infinite spinner.
      Row({ space: 10 }) {
        Image($r('app.media.startIcon'))
          .width(40)
          .height(40)
          .rotate({ angle: this.spinAngle })
          .animation({ duration: 1000, iterations: -1, playMode: PlayMode.Normal })
        Text('③ 无限旋转 loading（iterations: -1）')
          .fontSize(13)
          .fontColor('#666')
      }
      .margin({ top: 4 })

      Button('返回')
        .width('80%')
        .margin({ top: 8 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
