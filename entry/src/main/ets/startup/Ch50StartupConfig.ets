// Chapter 50: the configEntry — where the startup framework begins.
//
// onConfig() is called before any task runs, so it is the only honest t0 for a
// startup timeline. onCompleted() fires when the last automatic task finishes;
// comparing it with AbilityStage.onCreate tells you whether the UI thread was
// actually waiting.
import { StartupConfig, StartupConfigEntry, StartupListener } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { Ch50Trace } from '../pages/ch50data/Ch50Trace'

class Ch50StartupListener extends StartupListener {
  onCompleted(error: BusinessError<void>): void {
    Ch50Trace.tCompleted = Date.now()
  }
}

export default class Ch50StartupConfig extends StartupConfigEntry {
  onConfig(): StartupConfig {
    Ch50Trace.tConfig = Date.now()
    const config: StartupConfig = {
      timeoutMs: 5000,
      startupListener: new Ch50StartupListener()
    }
    return config
  }
}
