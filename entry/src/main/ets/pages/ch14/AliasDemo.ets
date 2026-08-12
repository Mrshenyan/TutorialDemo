// Chapter 14 demo: @Provide / @Consume paired by alias when variable names differ.
@Entry
@Component
struct GrandpaAlias {
  // @Provide with an alias 'userId'. (Field named userIdValue to avoid shadowing CustomComponent.id)
  @Provide('userId') userIdValue: number = 1001

  build() {
    Column() {
      Text(`祖先 id: ${this.userIdValue}`)
        .margin(10)

      Button('祖先 +1')
        .onClick(() => {
          this.userIdValue++
        })
        .margin(10)

      MiddleAlias()
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct MiddleAlias {
  build() {
    ChildAlias()
  }
}

@Component
struct ChildAlias {
  // @Consume with the SAME alias; variable name can differ from the ancestor.
  @Consume('userId') userId: number

  build() {
    Column() {
      Text(`后代 userId: ${this.userId}`)
        .margin(10)

      Button('后代 +1')
        .onClick(() => {
          this.userId++
        })
        .margin(10)
    }
  }
}
