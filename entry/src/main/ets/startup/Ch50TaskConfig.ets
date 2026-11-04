// Chapter 50: task 1 — read remote/AB config.
//
// This one is configured with runOnThread: mainThread and waitOnMainThread: true,
// so it must stay short. 60 ms is already generous; anything that touches the
// network or the disk belongs in a taskPool task instead.
import { StartupTask, common } from '@kit.AbilityKit'

@Sendable
export default class Ch50TaskConfig extends StartupTask {
  constructor() {
    super()
  }

  async init(context: common.AbilityStageContext): Promise<Object | void> {
    const t0: number = Date.now()
    let acc: number = 0
    while (Date.now() - t0 < 60) {
      acc += Math.sqrt(acc + 1)
    }
    // "start|cost" — start is an absolute Date.now() on the same clock the main
    // thread uses, so the page can draw the task's real [start, end] interval and
    // prove whether two taskPool tasks actually overlapped.
    return `${t0}|${Date.now() - t0}`
  }
}
