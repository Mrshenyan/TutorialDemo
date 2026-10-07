import { router } from '@kit.ArkUI'
import { common, Want } from '@kit.AbilityKit'

// Hosted by Ch38TargetAbility. Reads the parameter published by the ability
// via AppStorage, and can return a result via terminateSelfWithResult.
@Entry
@Component
struct Ch38TargetPage {
  @StorageProp('ch38Msg') msg: string = '(未收到参数)'

  // Return a result to the caller that used startAbilityForResult.
  backWithResult(): void {
    const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    // Strict-mode: build the result Want parameters Record via element assignment.
    let params: Record<string, Object> = {};
    params['reply'] = '目标 Ability 已收到并回传 ✅'
    const want: Want = { parameters: params }
    ctx.terminateSelfWithResult({ resultCode: 0, want: want })
  }

  build() {
    Column({ space: 16 }) {
      Text('Ch38TargetAbility 页面')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      Text('从 Want 收到的参数 msg：')
        .fontSize(14)
        .fontColor('#666')

      Text(this.msg)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)

      Button('返回并带回传结果')
        .width('90%')
        .backgroundColor('#317af7')
        .onClick(() => this.backWithResult())

      Button('直接关闭')
        .width('90%')
        .backgroundColor('#999')
        .onClick(() => {
          const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
          ctx.terminateSelf()
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Start)
  }
}
