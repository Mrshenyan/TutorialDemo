// Chapter 50: task 2 — warm the cache.
//
// runOnThread: taskPool + waitOnMainThread: false, so the UI thread never waits
// for these 420 ms. It only depends on Ch50TaskConfig.
import { StartupTask, common } from '@kit.AbilityKit'

@Sendable
export default class Ch50TaskCache extends StartupTask {
  constructor() {
    super()
  }

  async init(context: common.AbilityStageContext): Promise<Object | void> {
    const t0: number = Date.now()
    let acc: number = 0
    while (Date.now() - t0 < 420) {
      acc += Math.sqrt(acc + 1)
    }
    return `${t0}|${Date.now() - t0}`
  }
}
