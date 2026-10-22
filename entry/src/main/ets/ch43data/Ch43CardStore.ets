import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

/**
 * Chapter 43 - the single data source shared by the app and the widget.
 *
 * Two hard constraints drive the design:
 *   1. FormExtensionAbility.onAddForm() must return a FormBindingData
 *      *synchronously*. If you `await` inside it, the framework gets whatever
 *      you returned before the promise settles - which is nothing.
 *      => every read here uses the sync preferences API.
 *   2. The widget lives outside the UIAbility process, so it cannot share
 *      in-memory state with the main app. preferences (a file) is the channel;
 *      flushSync() commits it, otherwise the other side keeps reading cache.
 */

export const CH43_STORE_NAME: string = 'ch43_card_store'
export const CH43_KEY_DONE: string = 'done'
export const CH43_KEY_TARGET: string = 'target'
export const CH43_KEY_STREAK: string = 'streak'
export const CH43_KEY_TIME: string = 'updatedAt'

// Plain data holder. In ArkTS an object literal must map to an explicit
// class/interface, so we declare the shape once and reuse it everywhere.
export class Ch43Snapshot {
  done: number = 0
  target: number = 5
  streak: number = 0
  updatedAt: string = '--:--'
}

export class Ch43CardStore {
  // preferences.Options is a real interface, so a typed literal is allowed here.
  // (Record<string, Object> would NOT be - it is a type alias.)
  private static options(): preferences.Options {
    let opts: preferences.Options = { name: CH43_STORE_NAME }
    return opts
  }

  // Read the whole snapshot. Safe to call from both the app and the widget.
  static load(ctx: common.Context): Ch43Snapshot {
    let snap: Ch43Snapshot = new Ch43Snapshot()
    try {
      let store: preferences.Preferences = preferences.getPreferencesSync(ctx, Ch43CardStore.options())
      snap.done = store.getSync(CH43_KEY_DONE, 0) as number
      snap.target = store.getSync(CH43_KEY_TARGET, 5) as number
      snap.streak = store.getSync(CH43_KEY_STREAK, 0) as number
      snap.updatedAt = store.getSync(CH43_KEY_TIME, '--:--') as string
    } catch (e) {
      console.error(`[ch43] load failed: ${JSON.stringify(e)}`)
    }
    return snap
  }

  // Persist and commit immediately - flushSync() is what makes the value
  // visible to the other process.
  static save(ctx: common.Context, snap: Ch43Snapshot): void {
    try {
      let store: preferences.Preferences = preferences.getPreferencesSync(ctx, Ch43CardStore.options())
      store.putSync(CH43_KEY_DONE, snap.done)
      store.putSync(CH43_KEY_TARGET, snap.target)
      store.putSync(CH43_KEY_STREAK, snap.streak)
      store.putSync(CH43_KEY_TIME, snap.updatedAt)
      store.flushSync()
    } catch (e) {
      console.error(`[ch43] save failed: ${JSON.stringify(e)}`)
    }
  }

  // +1 button on the card, or the same button inside the app.
  // Reaching the daily target rolls the counter over and grows the streak.
  static bump(ctx: common.Context): Ch43Snapshot {
    let snap: Ch43Snapshot = Ch43CardStore.load(ctx)
    snap.done = snap.done + 1
    if (snap.done >= snap.target) {
      snap.done = 0
      snap.streak = snap.streak + 1
    }
    snap.updatedAt = Ch43CardStore.nowText()
    Ch43CardStore.save(ctx, snap)
    return snap
  }

  static reset(ctx: common.Context): Ch43Snapshot {
    let snap: Ch43Snapshot = Ch43CardStore.load(ctx)
    snap.done = 0
    snap.streak = 0
    snap.updatedAt = Ch43CardStore.nowText()
    Ch43CardStore.save(ctx, snap)
    return snap
  }

  static nowText(): string {
    let d: Date = new Date()
    let hh: string = d.getHours() < 10 ? `0${d.getHours()}` : `${d.getHours()}`
    let mm: string = d.getMinutes() < 10 ? `0${d.getMinutes()}` : `${d.getMinutes()}`
    return `${hh}:${mm}`
  }

  // FormBindingData takes an Object. ArkTS forbids inline literals here, and
  // Record<string, Object> = {...} is rejected too, so build it key by key.
  // An empty {} is the only literal the compiler tolerates.
  //
  // `dimension` is optional on purpose: only onAddForm knows the real widget
  // size. updateForm() merges keys into the card's LocalStorage, so leaving it
  // out keeps whatever the card already has instead of resetting it to 2*2.
  static toBindingData(snap: Ch43Snapshot, dimension?: number): Record<string, Object> {
    let rec: Record<string, Object> = {}
    rec['done'] = snap.done
    rec['target'] = snap.target
    rec['streak'] = snap.streak
    rec['updatedAt'] = snap.updatedAt
    if (dimension !== undefined) {
      rec['dimension'] = dimension
    }
    return rec
  }
}
