// Chapter 50: a main-thread stopwatch shared by the startup hooks and the page.
//
// AppStartup's tasks may run on taskPool threads, and they cannot touch this
// object (it is not Sendable). So this file only records the MAIN THREAD
// milestones; per-task cost comes back through startupManager.getStartupTaskResult().
//
// Static fields are re-initialised on every cold start, which is exactly what we
// want: the page always shows the current launch, not the previous one.
export class Ch50Trace {
  static tConfig: number = 0      // StartupConfigEntry.onConfig — framework starts
  static tCompleted: number = 0   // StartupListener.onCompleted — every task done
  static tAbilityStage: number = 0// AbilityStage.onCreate
  static tAbilityCreate: number = 0// EntryAbility.onCreate
  static tWindowStage: number = 0 // onWindowStageCreate (content not loaded yet)
  static tPageAppear: number = 0  // first page aboutToAppear

  static reset(): void {
    Ch50Trace.tConfig = 0
    Ch50Trace.tCompleted = 0
    Ch50Trace.tAbilityStage = 0
    Ch50Trace.tAbilityCreate = 0
    Ch50Trace.tWindowStage = 0
    Ch50Trace.tPageAppear = 0
  }

  // Milliseconds since onConfig(), or -1 when that milestone never ran.
  static sinceConfig(t: number): number {
    if (Ch50Trace.tConfig === 0 || t === 0) {
      return -1
    }
    return t - Ch50Trace.tConfig
  }
}
