import { router } from '@kit.ArkUI'
import { common, Want } from '@kit.AbilityKit'

interface BizErr { code: number; message: string }

// startAbilityForResult → same target ability, but the target calls
// terminateSelfWithResult; the result arrives in the promise.
@Entry
@Component
struct Ch38ResultBack {
  @State result: string = '点击后等待目标 Ability 回传结果'

  private launchForResult(): void {
    const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    // Strict-mode: build the Want parameters Record via element assignment.
    let params: Record<string, Object> = {};
    params['msg'] = '请回传一句话'
    const want: Want = {
      bundleName: 'com.cc.tutorialdemo',
      abilityName: 'Ch38TargetAbility',
      parameters: params
    }
    ctx.startAbilityForResult(want).then((data: common.AbilityResult) => {
      const reply: string = (data.want && data.want.parameters)
        ? (data.want.parameters['reply'] as string)
        : '(无回传)'
      this.result = `resultCode=${data.resultCode}，回传：${reply}`
    }).catch((e: Object) => {
      const be: BizErr = e as BizErr
      this.result = `失败[${be.code}]：${be.message}`
    })
  }

  build() {
    Column({ space: 14 }) {
      Text('startAbilityForResult 回传结果')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      Text('目标 Ability 关闭时通过 terminateSelfWithResult 回传')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      Button('启动并等待回传')
        .width('90%')
        .backgroundColor('#D32F2F')
        .onClick(() => this.launchForResult())

      Text(this.result)
        .fontSize(14)
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
