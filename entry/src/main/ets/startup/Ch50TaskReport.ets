// Chapter 50: task 4 — the one that should NOT run at launch.
//
// excludeFromAutoStart: true puts it in manual mode. Nothing happens until a
// page calls startupManager.run(['Ch50TaskReport']). A report builder nobody
// opens on the first screen has no business costing 300 ms of startup time.
import { StartupTask, common } from '@kit.AbilityKit'

@Sendable
export default class Ch50TaskReport extends StartupTask {
  constructor() {
    super()
  }

  async init(context: common.AbilityStageContext): Promise<Object | void> {
    const t0: number = Date.now()
    let acc: number = 0
    while (Date.now() - t0 < 300) {
      acc += Math.sqrt(acc + 1)
    }
    return `${t0}|${Date.now() - t0}`
  }
}
