import { router } from '@kit.ArkUI'
import { common, Want } from '@kit.AbilityKit'

interface BizErr { code: number; message: string }

// Explicit Want → a SECOND UIAbility in the SAME app (Ch38TargetAbility).
// We fill bundleName + abilityName + parameters, so no system resolver is involved.
@Entry
@Component
struct Ch38ExplicitSameApp {
  @State input: string = '你好，目标 Ability'
  @State log: string = '点「跳转」用显式 Want 启动 Ch38TargetAbility 并传参'

  private launch(): void {
    const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    let params: Record<string, Object> = {};
    params['msg'] = this.input
    const want: Want = {
      bundleName: 'com.cc.tutorialdemo',
      abilityName: 'Ch38TargetAbility',
      parameters: params
    }
    ctx.startAbility(want).then(() => {
      this.log = '已显式启动目标 Ability'
    }).catch((e: Object) => {
      const be: BizErr = e as BizErr
      this.log = `失败[${be.code}]：${be.message}`
    })
  }

  build() {
    Column({ space: 14 }) {
      Text('显式 Want 跳同应用 Ability（传参）')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      Text('bundleName + abilityName 精确指定目标，parameters 携带参数')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      TextInput({ text: this.input, placeholder: '要传递的参数' })
        .width('90%')
        .onChange((v: string): void => { this.input = v })

      Button('跳转到 Ch38TargetAbility')
        .width('90%')
        .backgroundColor('#317af7')
        .onClick(() => this.launch())

      Text(this.log)
        .fontSize(13)
        .fontColor('#444')
        .width('90%')
        .fontFamily('monospace')

      Button('返回')
        .width('90%')
        .margin({ top: 8 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Start)
  }
}
