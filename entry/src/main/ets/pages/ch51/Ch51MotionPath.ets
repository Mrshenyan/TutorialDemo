// Chapter 51 §C: motionPath — fly along an SVG path instead of a straight line.
//
// Without motionPath, animateTo interpolates position attributes linearly
// (well, along the curve). With .motionPath() set on the component, the SAME
// position change is routed through the SVG path string instead.
//
// Contract learned from testing:
//  1. The path's start point is the component's CURRENT top-left (treat it as
//     origin 0,0); the path END point must equal the position delta of the
//     animated change, or the component stops short.
//  2. UNIT TRAP (found by screenshot): path coordinates are PX while
//     .translate() is VP. On a ~2.96x screen a path ending at "260" only moves
//     the component ~88 vp — it stops mid-way and never reaches the target.
//     Fix: multiply by display.getDefaultDisplaySync().densityPixels.
//  3. Only driven by animateTo/animation on a position-affecting attribute
//     (here: .translate). Setting motionPath alone animates nothing.
//  4. rotatable: true rotates the component to follow the path tangent —
//     great for planes/arrows, wrong for balls.
import { curves, display } from '@kit.ArkUI'

@Entry
@Component
struct Ch51MotionPathPage {
  @State posX: number = 0
  @State log: string = '点按钮，小球沿 S 曲线飞到右边'
  private readonly targetX: number = 260
  private readonly density: number = display.getDefaultDisplaySync().densityPixels

  private fly(): void {
    const going: boolean = this.posX === 0
    // Path is in PX, translate is in VP — convert or the ball stops halfway.
    const endPx: number = Math.round(this.targetX * this.density)
    this.getUIContext()?.animateTo({ duration: 1200, curve: Curve.EaseInOut }, () => {
      this.posX = going ? this.targetX : 0
    })
    this.log = going
      ? `路径终点 ${endPx}px（= ${this.targetX}vp × 密度 ${this.density}），和 translate 的位移差按 px 对齐，稳稳落位`
      : '原路飞回起点'
  }

  build() {
    Column({ space: 12 }) {
      Text('C · motionPath 路径动画')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Text('同样一个 translate 动画，挂上 motionPath 之后不再是直线——插值被路由到 SVG 路径上。rotatable 开着时组件还会沿切线转头。')
        .fontSize(13)
        .fontColor('#666')
        .width('92%')

      // The flight stage. Path: S-curve starting at (0,0), ending at
      // (260 * density, 0) — exactly the px delta the translate applies.
      Stack({ alignContent: Alignment.TopStart }) {
        // Ghost rails so the eye can see the path the ball takes.
        Text('S 曲线轨道')
          .fontSize(11)
          .fontColor('#ccc')
          .margin({ top: 30, left: 8 })

        Circle({ width: 36, height: 36 })
          .fill('#1565C0')
          .translate({ x: this.posX, y: 0 })
          .motionPath({
            path: `M0 0 C ${72 * this.density} 0 ${72 * this.density} ${-120 * this.density} ${130 * this.density} ${-120 * this.density} C ${187 * this.density} ${-120 * this.density} ${187 * this.density} 0 ${this.targetX * this.density} 0`,
            rotatable: false
          } as MotionPathOptions)
      }
      .width('92%')
      .height(180)
      .borderRadius(12)
      .backgroundColor('#FAFAFA')

      // Same flight, but the arrow rotates with the tangent.
      Stack({ alignContent: Alignment.TopStart }) {
        Text('↗ 箭头会沿切线转头（rotatable: true）')
          .fontSize(11)
          .fontColor('#ccc')
          .margin({ top: 30, left: 8 })

        Text('➤')
          .fontSize(30)
          .fontColor('#C62828')
          .translate({ x: this.posX, y: 60 })
          .motionPath({
            path: `M0 0 C ${72 * this.density} 0 ${72 * this.density} ${-120 * this.density} ${130 * this.density} ${-120 * this.density} C ${187 * this.density} ${-120 * this.density} ${187 * this.density} 0 ${this.targetX * this.density} 0`,
            rotatable: true
          } as MotionPathOptions)
      }
      .width('92%')
      .height(180)
      .borderRadius(12)
      .backgroundColor('#FAFAFA')

      Button('起飞 / 返回')
        .width('92%')
        .backgroundColor('#6A1B9A')
        .onClick(() => this.fly())

      Text(this.log)
        .fontSize(13)
        .fontColor('#317af7')
        .width('92%')
        .padding(10)
        .borderRadius(8)
        .backgroundColor('#F5F5F5')

      Text('踩坑：path 的坐标单位是 px，translate 是 vp——不乘密度，小球只飞到一半就"到站"；路径终点必须等于这次位置变化的位移差；路径起点固定当作 (0,0)，别写组件的绝对坐标。')
        .fontSize(12)
        .fontColor('#888')
        .width('92%')
    }
    .width('100%')
    .height('100%')
  }
}
