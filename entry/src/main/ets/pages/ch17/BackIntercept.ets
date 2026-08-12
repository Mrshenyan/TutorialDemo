import { promptAction } from '@kit.ArkUI'

// Chapter 17 §4.2: intercept the back gesture when there is unsaved content.

@Entry
@Component
struct BackInterceptPage {
  @Provide pageStack: NavPathStack = new NavPathStack()

  @Builder
  PageMap(name: string) {
    if (name === 'EditPage') {
      EditPage()
    }
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Text('我是首页')
          .fontSize(24)
          .margin({ top: 100 })

        Button('去编辑页')
          .margin({ top: 20 })
        .onClick(() => {
          let param: Record<string, Object> = {}
          this.pageStack.pushPathByName('EditPage', param)
        })
      }
      .width('100%')
      .height('100%')
    }
    .title('首页')
    .mode(NavigationMode.Stack)
    .navDestination(this.PageMap)
  }
}

@Component
export struct EditPage {
  @Consume pageStack: NavPathStack
  @State hasUnsaved: boolean = false

  build() {
    NavDestination() {
      Column() {
        Text('编辑页').fontSize(22).margin({ top: 40 })

        TextInput({ text: '', placeholder: '输入内容...' })
          .margin({ top: 16 })
          .onChange(() => {
            this.hasUnsaved = true
          })

        Button('保存并返回')
          .margin({ top: 20 })
          .onClick(() => {
            this.hasUnsaved = false
            this.pageStack.pop()
          })

        Button('返回')
          .margin({ top: 12 })
          .onClick(() => {
            if (this.hasUnsaved) {
              promptAction.showToast({ message: '有未保存内容，拦截返回' })
            }else{
              this.pageStack.pop()
            }
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .title('编辑')
    .onBackPressed(() => {
      // Intercept system back / swipe-back. Return true = handled (don't leave).
      if (this.hasUnsaved) {
        promptAction.showToast({ message: '有未保存内容，拦截返回' })
        return true // intercept
      }
      return false // allow normal back
    })
  }
}
