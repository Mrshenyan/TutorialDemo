// Chapter 48 concurrent functions.
// @Concurrent functions must live at the top level of a file and must not touch
// `this` or any outer variable -- everything they need arrives as an argument.
import { collections } from '@kit.ArkTS'
import { PlainCounter, SharedCounter, SharedInventory } from './Ch48Models'

// Receives a CLONE. Bumping it has no effect on the caller's object.
@Concurrent
export function bumpPlain(c: PlainCounter): number {
  c.value += 100
  return c.value
}

// Receives the SAME instance. The caller sees the new value afterwards.
@Concurrent
export function bumpShared(c: SharedCounter): number {
  c.value += 100
  return c.value
}

// Touching a Sendable container from a worker thread.
@Concurrent
export function fillInventory(inv: SharedInventory, name: string, rounds: number): number {
  for (let i = 0; i < rounds; i++) {
    inv.add(name, 1)
  }
  return inv.items.get(name) ?? 0
}

// Cost probe: a plain number[] is cloned element by element.
@Concurrent
export function sumPlain(arr: number[]): number {
  let total: number = 0
  for (let i = 0; i < arr.length; i++) {
    total += arr[i]
  }
  return total
}

// Cost probe: a collections.Array is shared, nothing is copied.
@Concurrent
export function sumSendable(arr: collections.Array<number>): number {
  let total: number = 0
  for (let i = 0; i < arr.length; i++) {
    total += arr[i]
  }
  return total
}

// Transfer-only probe: the worker does almost nothing, so the measured time is
// dominated by "moving the data across", not by "reading it element by element".
@Concurrent
export function peekPlainLength(arr: number[]): number {
  return arr.length
}

@Concurrent
export function peekSendableLength(arr: collections.Array<number>): number {
  return arr.length
}
