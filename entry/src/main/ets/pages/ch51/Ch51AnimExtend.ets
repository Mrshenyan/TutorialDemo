// Chapter 51 §D: @AnimatableExtend — teach animation() a new trick.
//
// ch8 introduced @Extend for style reuse. @Extend functions are NOT animatable:
// a state change routed through an @Extend function swaps the value instantly.
// @AnimatableExtend is the same shape, but the framework interpolates the
// wrapped attributes between old and new values when driven by animation() or
// animateTo.
//
// Two usage notes encoded below:
//  1. Only attribute-method calls may appear inside the function body.
//  2. The component still needs a driver — here .animation() on the Text
//     (attribute animation) animates the @AnimatableExtend call when the
//     state variable changes.
// One function can wrap SEVERAL attributes; they all interpolate together.

// Wraps fontSize + fontColor so one state flip animates both in sync.
@AnimatableExtend(Text)
function animTitle(size: number) {
  .fontSize(size)
  .fontColor(size > 40 ? '#C62828' : '#1565C0')
}

// The @Extend contrast case: identical body, but no interpolation — it snaps.
@Extend(Text)
function snapTitle(size: number) {
  .fontSize(size)
  .fontColor(size > 40 ? '#C62828' : '#1565C0')
}

@Entry
@Component
struct Ch51AnimExtendPage {
  @State big: boolean = false
  @State log: string = '分别点两个按钮，感受"插值"和"瞬切"的区别'

  private nextSize(): number {
    return this.big ? 56 : 22
  }

  build() {
    Column({ space: 12 }) {
      Text('D · @AnimatableExtend 自定义可动画属性')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Text('ch8 的 @Extend 只能复用样式，不能动画。@AnimatableExtend 长得一样，但包在里面的属性会被框架逐帧插值——相当于自己给 animation() 注册了一个"可动画属性"。')
        .fontSize(13)
        .fontColor('#666')
        .width('92%')

      Text('对比一：@AnimatableExtend')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#317af7')
        .width('92%')

      Text('我会平滑变大')
        .animTitle(this.nextSize())
        .animation({ duration: 600, curve: Curve.EaseInOut })
        .width('92%')
        .padding(8)

      Button('切换 @AnimatableExtend 版本')
        .width('92%')
        .backgroundColor('#1565C0')
        .onClick(() => {
          this.big = !this.big
          this.log = 'animTitle：fontSize 和 fontColor 一起被插值，600ms 平滑过渡'
        })

      Text('对比二：普通 @Extend')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#C62828')
        .width('92%')
        .margin({ top: 8 })

      Text('我是瞬切的')
        .snapTitle(this.nextSize())
        .animation({ duration: 600, curve: Curve.EaseInOut })
        .width('92%')
        .padding(8)

      Button('切换普通 @Extend 版本')
        .width('92%')
        .backgroundColor('#C62828')
        .onClick(() => {
          this.big = !this.big
          this.log = 'snapTitle：同样挂了 .animation()，但 @Extend 不参与插值——直接跳变'
        })

      Text(this.log)
        .fontSize(13)
        .fontColor('#317af7')
        .width('92%')
        .padding(10)
        .borderRadius(8)
        .backgroundColor('#F5F5F5')

      Text('踩坑：函数体里只能写属性方法；@AnimatableExtend 标记的是"函数里包的属性可插值"，不是"函数自己会动"——驱动仍然是 animation() 或 animateTo。')
        .fontSize(12)
        .fontColor('#888')
        .width('92%')
    }
    .width('100%')
    .height('100%')
  }
}
