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
 *   3. A preferences file maps to ONE cached in-memory instance per process,
 *      and that instance never re-reads the file. So every read/write goes
 *      through openFresh(): removePreferencesFromCacheSync() first, then
 *      getPreferencesSync() - otherwise the app serves startup-time values
 *      forever and desktop check-ins never show up.
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

  // A preferences file maps to exactly ONE in-memory instance per process, and
  // that instance eagerly loads the whole file into memory. The widget runs in
  // its own process, so after it flushSync()s, this process's instance still
  // serves the stale values it loaded at startup - that is why "check-in on the
  // desktop, reopen the app, nothing changed" happens even though onPageShow
  // re-reads. Kick the instance out of the cache first, then re-open: the new
  // instance re-reads from disk. Local variable only, no dangling references.
  private static openFresh(ctx: common.Context): preferences.Preferences {
    try {
      preferences.removePreferencesFromCacheSync(ctx, Ch43CardStore.options())
    } catch (e) {
      // Nothing cached yet (first read in this process) - nothing to remove.
      console.info(`[ch43] cache empty, skip remove: ${JSON.stringify(e)}`)
    }
    return preferences.getPreferencesSync(ctx, Ch43CardStore.options())
  }

  // Read the whole snapshot. Safe to call from both the app and the widget.
  static load(ctx: common.Context): Ch43Snapshot {
    let snap: Ch43Snapshot = new Ch43Snapshot()
    try {
      let store: preferences.Preferences = Ch43CardStore.openFresh(ctx)
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
  // visible to the other process. openFresh() also guarantees we write on top
  // of what is currently on disk, never on top of a stale in-memory copy.
  static save(ctx: common.Context, snap: Ch43Snapshot): void {
    try {
      let store: preferences.Preferences = Ch43CardStore.openFresh(ctx)
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
