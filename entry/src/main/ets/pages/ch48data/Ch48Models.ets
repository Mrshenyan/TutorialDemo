// Chapter 48 data models: what actually crosses a thread boundary.
//
// Rule of thumb:
//   plain class  -> CLONED (structured clone). Same shape, different memory.
//   @Sendable    -> SHARED. Same memory, so mutations are visible on both sides.
import { collections } from '@kit.ArkTS'

// ---------- Plain class: copied across threads ----------
export class PlainCounter {
  value: number = 0

  constructor(value: number) {
    this.value = value
  }
}

// ---------- Sendable class: shared across threads ----------
// A @Sendable class may only hold number / string / boolean / other Sendable
// instances / collections.Array | Map | Set. A plain Map or a plain class here
// is a compile-time or runtime error.
@Sendable
export class SharedCounter {
  value: number = 0

  constructor(value: number) {
    this.value = value
  }
}

// Sendable container: collections.Map instead of Map.
@Sendable
export class SharedInventory {
  items: collections.Map<string, number> = new collections.Map<string, number>()

  add(name: string, count: number): void {
    const cur: number = this.items.get(name) ?? 0
    this.items.set(name, cur + count)
  }
}
