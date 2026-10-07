import { router } from '@kit.ArkUI'
import { common, Want } from '@kit.AbilityKit'

interface BizErr { code: number; message: string }

// Implicit Want → system apps. We only fill action (+uri/type), and the system
// resolver picks the matching app. No target ability needed.
@Entry
@Component
struct Ch38ImplicitSystem {
  @State log: string = '点击下方按钮，用隐式 Want 拉起系统应用'

  private ctx(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext
  }

  // 1) Open a web page in the default browser.
  openBrowser(): void {
    const want: Want = {
      action: 'ohos.want.action.viewData',
      uri: 'https://www.openharmony.cn',
      type: 'text/html'
    }
    this.ctx().startAbility(want).then(() => {
      this.log = '已拉起浏览器打开网页'
    }).catch((e: Object) => {
      const be: BizErr = e as BizErr
      this.log = `失败[${be.code}]：${be.message}`
    })
  }

  // 2) Open the dialer pre-filled with a number.
  openDialer(): void {
    const want: Want = {
      action: 'ohos.want.action.dial',
      uri: 'tel:10086'
    }
    this.ctx().startAbility(want).then(() => {
      this.log = '已拉起拨号盘'
    }).catch((e: Object) => {
      const be: BizErr = e as BizErr
      this.log = `失败[${be.code}]：${be.message}`
    })
  }

  // 3) Open system Settings.
  openSettings(): void {
    const want: Want = {
      action: 'ohos.want.action.settings'
    }
    this.ctx().startAbility(want).then(() => {
      this.log = '已拉起系统设置'
    }).catch((e: Object) => {
      const be: BizErr = e as BizErr
      this.log = `失败[${be.code}]：${be.message}`
    })
  }

  build() {
    Column({ space: 14 }) {
      Text('隐式 Want 拉起系统应用')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      Text('只填 action(+uri/type)，由系统决定由哪个应用响应')
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      Button('打开浏览器')
        .width('90%')
        .backgroundColor('#2E7D32')
        .onClick(() => this.openBrowser())

      Button('打开拨号盘')
        .width('90%')
        .backgroundColor('#6A1B9A')
        .onClick(() => this.openDialer())

      Button('打开系统设置')
        .width('90%')
        .backgroundColor('#317af7')
        .onClick(() => this.openSettings())

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
