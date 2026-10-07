import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'

const DOMAIN: number = 0x0038
const TAG: string = 'Ch38TargetAbility'

// Secondary UIAbility started by an EXPLICIT Want from the ch38 demos.
// It receives parameters through want.parameters and publishes them to the
// page via AppStorage, so the page stays decoupled from the ability lifecycle.
export default class Ch38TargetAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'onCreate, want=%{public}s', JSON.stringify(want))
    this.publishParam(want)
  }

  // If the ability is a singleton and already running, a new explicit start
  // triggers onNewWant instead of onCreate — a classic pitfall. Handle both.
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'onNewWant, want=%{public}s', JSON.stringify(want))
    this.publishParam(want)
  }

  private publishParam(want: Want): void {
    const params: Record<string, Object> | undefined = want.parameters
    const msg: string = params ? (params['msg'] as string) : '(未收到参数)'
    AppStorage.setOrCreate('ch38Msg', msg)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/ch38/Ch38TargetPage', (err: BusinessError) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        return
      }
      hilog.info(DOMAIN, TAG, 'loadContent succeeded')
    })
  }
}
