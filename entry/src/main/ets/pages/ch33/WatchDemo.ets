import { router } from '@kit.ArkUI';

// Demo ③-a (of ch33): @Watch fires a side-effect method whenever the bound variable changes.
// Unlike a computed property, @Watch runs AFTER the value updates and can do
// anything (logging, derived state, network calls).
@Entry
@Component
struct Ch33WatchDemo {
  // @Watch takes the NAME of a method in this component.
  @State @Watch('onCountChange') count: number = 0;
  @State @Watch('onCountChange') step: number = 1;
  @State log: string = '还没变化';

  // Called automatically after count or step changes. `this.count` is already the new value.
  onCountChange(): void {
    this.log = `变化了 -> count=${this.count}, step=${this.step}, 累计=${this.count * this.step}`;
  }

  build() {
    Column({ space: 14 }) {
      Text('@Watch 监听状态变化')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16 })

      Text(`当前 count: ${this.count}`)
        .fontSize(18)

      Row({ space: 12 }) {
        Button('-1').onClick(() => { this.count -= 1; })
        Button('+1').onClick(() => { this.count += 1; })
      }

      Text(`步长 step: ${this.step}`)
        .fontSize(15)
      Slider({ value: this.step, min: 1, max: 5, step: 1 })
        .width('80%')
        .onChange((v: number) => { this.step = v; })

      Text('副作用日志')
        .fontSize(14)
        .fontColor('#888')
      Text(this.log)
        .fontSize(15)
        .fontColor('#2E7D32')
        .width('90%')
        .backgroundColor('#F2F2F2')
        .padding(12)
        .borderRadius(8)

      Text('改 count 或 step，onCountChange 都会自动跑（@Watch 绑定的是方法名字符串）')
        .fontSize(12)
        .fontColor('#888')
        .width('90%')

      Button('返回')
        .width('80%')
        .margin({ top: 12 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
