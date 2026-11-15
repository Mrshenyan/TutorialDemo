// Chapter 51 §B: bindContentCover — fullscreen modal whose transition you own.
//
// ch20's pageTransition() only animates router page swaps. bindContentCover is
// lighter: a builder floats over the CURRENT page (no router entry, no lifecycle
// cost) and you choose how it comes in:
//   - modalTransition: DEFAULT  -> system slide-up, zero config
//   - modalTransition: NONE     -> framework does nothing; you pair
//     .transition(TransitionEffect.asymmetric(...)) on the builder root and
//     drive the show/hide through animateTo for a fully custom entrance.
//
// Pitfall encoded here: with NONE, if the boolean is flipped WITHOUT animateTo,
// the cover appears instantly and the transition effect never fires — same
// "must be driven by animateTo" rule as geometryTransition.
import { curves } from '@kit.ArkUI'

@Entry
@Component
struct Ch51ModalPage {
  @State showSystem: boolean = false
  @State showCustom: boolean = false
  @State log: string = '两种转场各试一次，注意进出场差异'

  // Builder 1: system DEFAULT transition (slide up).
  @Builder
  systemCover() {
    Column({ space: 16 }) {
      Text('系统转场（DEFAULT）')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#fff')
        .margin({ top: 60 })

      Text('一行配置：modalTransition: DEFAULT。框架自带上滑进场、下滑退场，覆盖层挂在当前页面之上，不走 router。')
        .fontSize(14)
        .fontColor('#ddd')
        .width('86%')

      Button('关掉我')
        .onClick(() => {
          this.getUIContext()?.animateTo({ duration: 250 }, () => {
            this.showSystem = false
          })
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1B5E20')
    .transition(TransitionEffect.OPACITY)
  }

  // Builder 2: custom transition. NONE disables the system animation; the
  // asymmetric effect decides: slide up + fade in, slide down + fade out.
  @Builder
  customCover() {
    Column({ space: 16 }) {
      Text('自定义转场（NONE）')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#fff')
        .margin({ top: 60 })

      Text('modalTransition: NONE 框架就撒手不管了。进场从下方 300vp 滑入 + 淡入，退场向下 300vp 滑出 + 淡出——全在 asymmetric 的两个 TransitionEffect 里。')
        .fontSize(14)
        .fontColor('#ddd')
        .width('86%')

      Button('关掉我')
        .onClick(() => {
          this.getUIContext()?.animateTo({ duration: 300, curve: curves.cubicBezierCurve(0.33, 0, 0.15, 1) }, () => {
            this.showCustom = false
          })
          this.log = '自定义退场：向下滑出 + 淡出'
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#4A148C')
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 350, curve: curves.cubicBezierCurve(0.33, 0, 0.15, 1) }),
      TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 300, curve: curves.cubicBezierCurve(0.33, 0, 0.15, 1) })
    ).combine(TransitionEffect.OPACITY))
  }

  build() {
    Column({ space: 12 }) {
      Text('B · bindContentCover 自定义模态转场')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Text('全屏浮层不必新开页面。bindContentCover 把一个 Builder 盖在当前页上，转场方式你自己挑：系统默认上滑，或者 NONE + TransitionEffect 全自定义。')
        .fontSize(13)
        .fontColor('#666')
        .width('92%')

      Button('看系统转场（DEFAULT）')
        .width('92%')
        .backgroundColor('#2E7D32')
        .onClick(() => {
          this.getUIContext()?.animateTo({ duration: 250 }, () => {
            this.showSystem = true
          })
          this.log = '系统转场：框架自带的上滑'
        })

      Button('看自定义转场（NONE）')
        .width('92%')
        .backgroundColor('#6A1B9A')
        .onClick(() => {
          this.getUIContext()?.animateTo({ duration: 350 }, () => {
            this.showCustom = true
          })
          this.log = '自定义进场：从底部滑入 + 淡入'
        })

      Text(this.log)
        .fontSize(13)
        .fontColor('#317af7')
        .width('92%')
        .padding(10)
        .borderRadius(8)
        .backgroundColor('#F5F5F5')

      Text('踩坑：flip 布尔值不包 animateTo，转场直接瞬切——NONE 模式下尤其明显，因为框架本来就不管动画了。')
        .fontSize(12)
        .fontColor('#888')
        .width('92%')
    }
    .width('100%')
    .height('100%')
    .bindContentCover(this.showSystem, this.systemCover(), { modalTransition: ModalTransition.DEFAULT } as ContentCoverOptions)
    .bindContentCover(this.showCustom, this.customCover(), { modalTransition: ModalTransition.NONE } as ContentCoverOptions)
  }
}
