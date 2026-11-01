// Chapter 47 data models.
// The through-line of this chapter:
//   V1: @Observed on EVERY level + one @ObjectLink component per level.
//   V2: @ObservedV2 once + @Trace on the fields you actually care about.

// ==================== V1 side ====================
// Plain-ish class: @Observed only makes the FIRST layer observable, so a
// three-level nested write still needs a matching @ObjectLink component.

@Observed
export class V1Address {
  city: string

  constructor(city: string) {
    this.city = city
  }
}

@Observed
export class V1User {
  name: string
  address: V1Address

  constructor(name: string, city: string) {
    this.name = name
    this.address = new V1Address(city)
  }
}

// ==================== V2 side ====================
// @ObservedV2 turns the instance into a tracked object; @Trace marks the
// properties (any depth, including Map/Set/Date) that should trigger a refresh.

@ObservedV2
export class V2Address {
  @Trace city: string
  // Deliberately NOT traced: flipping this one will stay invisible, which is
  // how you learn that @Trace is a whitelist, not a blanket switch.
  zipCode: string

  constructor(city: string, zipCode: string) {
    this.city = city
    this.zipCode = zipCode
  }
}

@ObservedV2
export class V2User {
  @Trace name: string
  @Trace address: V2Address

  constructor(name: string, city: string) {
    this.name = name
    this.address = new V2Address(city, '518000')
  }
}

// An order line used by the @Monitor / @Computed demo.
@ObservedV2
export class OrderLine {
  @Trace price: number
  @Trace count: number

  constructor(price: number, count: number) {
    this.price = price
    this.count = count
  }
}
