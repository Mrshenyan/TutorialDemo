// Chapter 50: AbilityStage is where automatic startup tasks are kicked off.
//
// Register it in module.json5 with a module-level `srcEntry`. Its onCreate runs
// after the framework has loaded the task list — if every task waits on the main
// thread, this timestamp is pushed back by the whole task duration.
import { AbilityStage } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Ch50Trace } from '../pages/ch50data/Ch50Trace'

export default class Ch50AbilityStage extends AbilityStage {
  onCreate(): void {
    Ch50Trace.tAbilityStage = Date.now()
    hilog.info(0x0000, 'ch50', 'AbilityStage.onCreate at +%{public}d ms',
      Ch50Trace.sinceConfig(Ch50Trace.tAbilityStage))
  }
}
