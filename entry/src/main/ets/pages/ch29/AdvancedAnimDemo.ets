import { router, curves, AnimatorOptions, AnimatorResult } from '@kit.ArkUI';

// Chapter 29 §高级: advanced gesture + animation techniques.
//
// This page bundles five production-grade topics:
//   A) Spring curves for follow-finger + interruptible feel (NOTE: responsiveSpringMotion /
//      springMotion are just ICurve interpolators; the follow/interrupt behavior comes from the
//      onActionUpdate re-targeting + engine's spring-velocity-inheritance, not the curve itself)
//   B) Keyframe animation (keyframeAnimateTo)
//   C) Custom cubic-bezier curve (curves.cubicBezier)
//   D) Frame-by-frame animation with Animator (onFrame / onFinish / onCancel / onRepeat)
//   E) Performance: renderGroup() to cache a subtree as a texture

@Entry
@Component
struct Ch29AdvancedAnim {
  // ---- A) Responsive spring ball ----
  @State ballX: number = 0;
  @State ballY: number = 0;
  private ballStartX: number = 0;
  private ballStartY: number = 0;

  // ---- B) Keyframe block ----
  @State kfRotate: number = 0;
  @State kfOffsetX: number = 0;
  @State kfOpacity: number = 1;

  // ---- C) Custom curve ball ----
  @State cbX: number = 0;

  // ---- D) Animator parabola ----
  @State animX: number = 0;
  @State animY: number = 0;
  @State animStatus: string = 'Created';
  private halfFired: boolean = false; // guards the one-shot key-frame event at value>=150
  private animatorResult: AnimatorResult | undefined = undefined;
  // Stored so reset() can re-apply the same parameters (reset REQUIRES AnimatorOptions).
  private animatorOptions: AnimatorOptions = {
    duration: 3000,
    easing: 'linear',
    delay: 0,
    fill: 'forwards',
    direction: 'normal',
    iterations: 1,
    begin: 0,
    end: 300
  };

  // ---- E) renderGroup windmill ----
  @State rgAngle: number = 0;

  aboutToAppear(): void {
    // D) Build the frame animator once. begin/end define the onFrame value range.
    const animator: AnimatorResult | undefined = this.getUIContext()?.createAnimator(this.animatorOptions);
    if (animator) {
      // onFrame: called every frame with the interpolated value (in [begin, end]).
      animator.onFrame = (value: number) => {
        // Horizontal: uniform; Vertical: parabola (t^2).
        this.animX = value;
        const t: number = value / 300;
        this.animY = t * t * 180;
        // ★ Key-frame event: fire ONCE when value first crosses 150 (mid-point).
        if (value >= 150 && !this.halfFired) {
          this.halfFired = true;
          console.info('progress >= 150: key-frame event triggered');
          // Put your own logic here: analytics, toast, state change, etc.
        }
      };
      // Lifecycle events. NOTE: Animator has NO onStart callback; the "start"
      // state is reflected by the Play button setting animStatus before play().
      animator.onFinish = () => { this.animStatus = 'Finished'; };
      animator.onCancel = () => { this.animStatus = 'Canceled'; };
      animator.onRepeat = () => { this.animStatus = 'Repeating'; };
      this.animatorResult = animator;
    }

    // E) rgAngle is animated in sectionE's onAppear (after the component is ready).
  }

  aboutToDisappear(): void {
    // Release the animator to avoid leaks.
    this.animatorResult = undefined;
  }

  build() {
    Scroll() {
      Column({ space: 22 }) {
        // ---- Title ----
        Text('第29篇 · 高级使用')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 16 })
        Text('跟手弹簧 · 关键帧 · 自定义曲线 · Animator 逐帧 · 性能优化')
          .fontSize(13)
          .fontColor('#666')

        // ============ A) Responsive spring + interruptible ============
        this.sectionA()

        // ============ B) Keyframe ============
        this.sectionB()

        // ============ C) Custom curve ============
        this.sectionC()

        // ============ D) Animator ============
        this.sectionD()

        // ============ E) renderGroup ============
        this.sectionE()

        Button('返回')
          .width('80%')
          .margin({ top: 8, bottom: 24 })
          .onClick(() => router.back())
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }

  // A) Spring curves for follow-finger + interruptible feel.
  //    IMPORTANT: responsiveSpringMotion / springMotion are just ICurve interpolators.
  //    "Follow finger" = re-target every frame in onActionUpdate; "interruptible +
  //    velocity inheritance" = engine's special treatment of spring curves (a new
  //    spring animation on the same attribute stops the old one and inherits its
  //    value+velocity). The curve alone does neither.
  @Builder
  sectionA() {
    Column({ space: 8 }) {
      Text('A. 弹簧曲线做跟手 + 可打断体验（responsiveSpringMotion / springMotion）')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)

      Column() {
        Circle({ width: 56, height: 56 })
          .fill('#1E88E5')
          .translate({ x: this.ballX, y: this.ballY })
      }
      .width('100%')
      .height(220)
      .backgroundColor('#F2F4F7')
      .borderRadius(12)
      .gesture(
        PanGesture({ fingers: 1 })
          .onActionStart((event: GestureEvent) => {
            this.ballStartX = this.ballX;
            this.ballStartY = this.ballY;
          })
          .onActionUpdate((event: GestureEvent) => {
            // Re-target every frame with a responsive spring curve. The spring
            // curve makes the per-frame transition elastic; the follow-finger
            // effect itself comes from re-targeting here, not from the curve.
            this.getUIContext()?.animateTo({ curve: curves.responsiveSpringMotion() }, () => {
              this.ballX = this.ballStartX + event.offsetX;
              this.ballY = this.ballStartY + event.offsetY;
            })
          })
          .onActionEnd(() => {
            // springMotion on the same attribute AUTOMATICALLY inherits the
            // velocity built up during the responsiveSpringMotion drag (engine
            // behavior) -> natural fling toward the snap point.
            this.getUIContext()?.animateTo({ curve: curves.springMotion() }, () => {
              this.ballX = 0;
              this.ballY = 0;
            })
          })
      )

      Text('拖我松手：每帧重设目标 + 弹簧曲线 = 跟手带弹性；离手 springMotion 自动继承速度滑回中心')
        .fontSize(12)
        .fontColor('#888')
        .alignSelf(ItemAlign.Start)
    }
  }

  // B) Keyframe animation: segmented tween via keyframeAnimateTo.
  @Builder
  sectionB() {
    Column({ space: 8 }) {
      Text('B. 关键帧动画（keyframeAnimateTo）')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)

      Column() {
        Text('点击我')
          .fontSize(16)
          .fontColor(Color.White)
          .rotate({ angle: this.kfRotate })
          .opacity(this.kfOpacity)
          .translate({ x: this.kfOffsetX })
          .backgroundColor('#7B1FA2')
          .width(120)
          .height(60)
          .borderRadius(10)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(140)
      .backgroundColor('#F2F4F7')
      .borderRadius(12)
      .onClick(() => {
        this.getUIContext()?.keyframeAnimateTo({ iterations: 1 }, [
          {
            // Segment 1: 800ms, spring curve.
            duration: 800,
            curve: curves.springMotion(),
            event: () => {
              this.kfRotate = 90;
              this.kfOpacity = 0.6;
              this.kfOffsetX = 60;
            }
          },
          {
            // Segment 2: 500ms, ease-out, back to start.
            duration: 500,
            curve: Curve.EaseOut,
            event: () => {
              this.kfRotate = 0;
              this.kfOpacity = 1;
              this.kfOffsetX = 0;
            }
          }
        ]);
      })

      Text('两段关键帧：先弹簧旋转+位移+半透明，再缓出复位')
        .fontSize(12)
        .fontColor('#888')
        .alignSelf(ItemAlign.Start)
    }
  }

  // C) Custom cubic-bezier curve.
  @Builder
  sectionC() {
    Column({ space: 8 }) {
      Text('C. 自定义曲线（curves.cubicBezier）')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)

      Column() {
        Circle({ width: 44, height: 44 })
          .fill('#00897B')
          .translate({ x: this.cbX })
      }
      .width('100%')
      .height(120)
      .backgroundColor('#F2F4F7')
      .borderRadius(12)
      .align(Alignment.Start)

      Button('用 cubicBezier(0.25,0.1,0.25,1) 平移')
        .width('90%')
        .backgroundColor('#00897B')
        .onClick(() => {
          const target: number = this.cbX === 0 ? 200 : 0;
          // A hand-tuned easing curve (CSS "ease" equivalent).
          this.getUIContext()?.animateTo(
            { duration: 800, curve: curves.cubicBezier(0.25, 0.1, 0.25, 1.0) },
            () => { this.cbX = target; }
          );
        })
    }
  }

  // D) Animator: per-frame callback + lifecycle events.
  @Builder
  sectionD() {
    Column({ space: 8 }) {
      Text('D. Animator 逐帧（onFrame / onFinish / onCancel / onRepeat）· 含关键帧事件')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)

      Column() {
        Circle({ width: 36, height: 36 })
          .fill('#E53935')
          .translate({ x: this.animX, y: this.animY })
      }
      .width('100%')
      .height(200)
      .backgroundColor('#F2F4F7')
      .borderRadius(12)
      .clip(true)
      .align(Alignment.Start)

      Text(`状态：${this.animStatus}  |  X=${this.animX.toFixed(0)} Y=${this.animY.toFixed(0)}`)
        .fontSize(12)
        .fontColor('#888')
        .alignSelf(ItemAlign.Start)

      Row({ space: 10 }) {
        Button('Play').onClick(() => { this.animStatus = 'Started'; this.halfFired = false; this.animatorResult?.play(); })
        Button('Pause').onClick(() => { this.animatorResult?.pause(); })
        Button('Reset').onClick(() => {
          this.animX = 0;
          this.animY = 0;
          this.animatorResult?.reset(this.animatorOptions);
        })
      }
      .width('100%')

      Text('onFrame 里 value 越过 150（过半）时触发一次"关键帧事件"，看控制台日志')
        .fontSize(12)
        .fontColor('#888')
        .alignSelf(ItemAlign.Start)
    }
  }

  // E) renderGroup: cache a static subtree as a texture, animate the parent only.
  @Builder
  sectionE() {
    Column({ space: 8 }) {
      Text('E. 性能优化（renderGroup 缓存子树）')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)

      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.startIcon'))
          .width(64)
          .height(64)
        Image($r('app.media.startIcon'))
          .width(64)
          .height(64)
          .rotate({ angle: 90 })
        Image($r('app.media.startIcon'))
          .width(64)
          .height(64)
          .rotate({ angle: 180 })
        Image($r('app.media.startIcon'))
          .width(64)
          .height(64)
          .rotate({ angle: 270 })
      }
      .width(140)
      .height(140)
      // renderGroup caches the 4 static images into ONE texture; the spin below
      // only transforms that texture (no per-frame redraw of the subtree).
      .renderGroup(true)
      .rotate({ angle: this.rgAngle })
      .onAppear(() => {
        // Spin continuously; renderGroup makes each frame only transform the cached texture.
        this.getUIContext()?.animateTo({ duration: 6000, curve: Curve.Linear, iterations: -1 }, () => {
          this.rgAngle = 3600;
        });
      })

      Text('父组件统一旋转、子组件为静态资源：开启 renderGroup 后每次旋转只变换缓存纹理')
        .fontSize(12)
        .fontColor('#888')
        .alignSelf(ItemAlign.Start)
    }
  }
}
