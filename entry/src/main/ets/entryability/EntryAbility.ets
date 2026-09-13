import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { uiAppearance, window } from '@kit.ArkUI';
import resourceManager from '@ohos.resourceManager';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  // Push the CURRENT system configuration into AppStorage under app-owned keys, so pages can
  // read them live via @StorageProp. We use OUR OWN keys (sys.colorMode / sys.fontSizeScale)
  // instead of Environment's colorMode/fontScale, because on HarmonyOS 5 (API 12+) Environment's
  // colorMode/fontScale do NOT sync back to AppStorage when system settings change (a known
  // framework behavior — only languageCode/fontWeightScale follow). See ch33 Environment demo.
  private syncSystemConfig(): void {
    // colorMode: resourceManager.Configuration HAS colorMode (since API 12).
    try {
      const cfg: resourceManager.Configuration = this.context.resourceManager.getConfigurationSync();
      AppStorage.setOrCreate('sys.colorMode', cfg.colorMode ?? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    } catch (e) {
      hilog.error(DOMAIN, 'testTag', 'syncSystemConfig colorMode failed: %{public}s', JSON.stringify(e));
    }
    // fontScale: resourceManager.Configuration has NO font field. The system font scale must come
    // from uiAppearance.getFontScale() (since API 20). Project target is API 24, so it is available.
    try {
      AppStorage.setOrCreate('sys.fontSizeScale', uiAppearance.getFontScale());
    } catch (e) {
      hilog.error(DOMAIN, 'testTag', 'syncSystemConfig fontScale failed: %{public}s', JSON.stringify(e));
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // ① Sync system config once at startup so the first page already shows the real mode/scale.
    this.syncSystemConfig();

    // ② Environment is still usable, but it only provides a READ-ONLY SNAPSHOT: on HarmonyOS 5,
    //    its colorMode/fontScale do NOT follow live system-setting changes (verified on the
    //    Huawei dev forum — languageCode/fontWeightScale DO follow). Kept here only for contrast
    //    teaching; for live updates use onConfigurationUpdate below.
    Environment.envProp('colorMode', 1);   // default light if system value unavailable
    Environment.envProp('fontScale', 1.0); // system font scale (e.g. 1.0 / 1.5)

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'Succeeded in loading the content.');
    });
  }

  // ③ Live system-configuration callback — the AUTHORITATIVE way to follow dark-mode / font-scale
  //    changes. Fires when the user toggles dark mode or changes font size in system Settings.
  onConfigurationUpdate(newConfig: Configuration): void {
    AppStorage.setOrCreate('sys.colorMode', newConfig.colorMode ?? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    AppStorage.setOrCreate('sys.fontSizeScale', newConfig.fontSizeScale ?? 1.0);
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
