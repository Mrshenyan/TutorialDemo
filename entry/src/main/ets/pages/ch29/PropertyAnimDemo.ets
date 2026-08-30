import { router } from '@kit.ArkUI';

// Chapter 29 §二: implicit property animation — animation().
//
// Rule that trips up everyone: `.animation()` only animates the properties
// declared AFTER it on the SAME component. Put it before .width(), and the
// width change will JUMP instead of tween.
@Entry
@Component
struct Ch29PropertyAnim {
  @State expanded: boolean = false;

  build() {
    Column({ space: 24 }) {
      Text('属性动画 animation()')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Button(this.expanded ? '收起' : '展开')
        .onClick(() => { this.expanded = !this.expanded })

      // ① CORRECT order: animation() comes AFTER the animated properties.
      Column() {
        Text('✅ 顺序正确：会平滑过渡')
          .fontSize(12)
          .fontColor('#2E7D32')
      }
      .width(this.expanded ? 220 : 120)
      .height(this.expanded ? 120 : 60)
      .backgroundColor(this.expanded ? Color.Green : Color.Orange)
      .borderRadius(12)
      .animation({ duration: 450, curve: Curve.EaseInOut })

      // ② WRONG order: animation() BEFORE width/height, so size JUMPS;
      //    only the backgroundColor declared after it still tweens.
      Column() {
        Text('❌ 顺序错误：尺寸瞬变，仅颜色过渡')
          .fontSize(12)
          .fontColor('#C62828')
      }
      .animation({ duration: 450, curve: Curve.EaseInOut })
      .width(this.expanded ? 220 : 120)
      .height(this.expanded ? 120 : 60)
      .backgroundColor(this.expanded ? Color.Green : Color.Orange)
      .borderRadius(12)

      Text('结论：先写要动的属性，最后再写 .animation()')
        .fontSize(13)
        .fontColor('#666')
        .padding({ left: 16, right: 16 })

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
