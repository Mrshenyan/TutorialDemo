// Chapter 47: demo-only instrumentation.
// Static counters are NOT part of any state system, so bumping them never
// triggers a re-render. That is exactly what makes them usable as a probe:
// the numbers only move when the getter / method really runs.
//
// Do not copy this into production code -- @Computed getters should stay pure.
export class Ch47Stats {
  static computedHits: number = 0
  static plainHits: number = 0
}
