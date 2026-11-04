// Chapter 50: task 3 — prefetch the first screen of data.
//
// Also taskPool. It depends on the config task but NOT on the cache task, which
// is the whole point: cache (420 ms) and feed (380 ms) run at the same time, so
// the launch pays ~420 ms instead of 800 ms.
import { StartupTask, common } from '@kit.AbilityKit'

@Sendable
export default class Ch50TaskFeed extends StartupTask {
  constructor() {
    super()
  }

  async init(context: common.AbilityStageContext): Promise<Object | void> {
    const t0: number = Date.now()
    let acc: number = 0
    while (Date.now() - t0 < 380) {
      acc += Math.sqrt(acc + 1)
    }
    return `${t0}|${Date.now() - t0}`
  }
}
