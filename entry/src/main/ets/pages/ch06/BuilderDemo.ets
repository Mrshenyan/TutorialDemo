// Chapter 6 demo: member @Builder, global @Builder, and value vs reference passing.

// Global @Builder: accessible app-wide, NO this / bind. Passes by VALUE by default.
@Builder function globalValueBuilder(paramA1: string) {
  Row() {
    Text(`value: ${paramA1}`)
  }
}

// Named interface for the reference-passing param (ArkTS forbids inline object-literal types).
interface RefParam {
  txt: string
}

// Global @Builder that takes a single object-literal param -> REFERENCE passing.
// Changing the state var inside the object refreshes this builder's UI.
@Builder function globalRefBuilder(param: RefParam) {
  Row() {
    Text(`ref: ${param.txt}`)
  }
}

@Entry
@Component
struct BuilderDemo {
  @State label: string = 'Hello'

  // Member @Builder: `this` points to the current component, can read state.
  @Builder memberBuilder() {
    Text(`member: ${this.label}`)
  }

  build() {
    Column({ space: 12 }) {
      Text('成员 Builder（可访问状态）').fontSize(14).fontColor('#666')
      this.memberBuilder()

      Text('全局 Builder（默认值传递：改 label 不会刷新）').fontSize(14).fontColor('#666')
      globalValueBuilder(this.label)

      Text('全局 Builder（引用传递：改 label 会刷新）').fontSize(14).fontColor('#666')
      globalRefBuilder({ txt: this.label })

      Button('改变 label')
        .onClick(() => {
          this.label = 'ArkUI'
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
