// Chapter 19 §6.1-§6.2: bindMenu (click) + bindContextMenu (long press).

@Entry
@Component
struct MenuDemo {
  @State showMenu: boolean = false

  @Builder
  ctxMenuBuilder() {
    Menu() {
      MenuItem({ startIcon: $r('app.media.startIcon'), content: '复制', labelInfo: 'Ctrl+C' })
        .onClick(() => { console.log('复制') })
      MenuItem({ content: '粘贴' })
        .onClick(() => { console.log('粘贴') })

      MenuItemGroup({ header: '更多' }) {
        MenuItem({ content: '转发' }).onClick(() => {})
        MenuItem({ content: '收藏' }).onClick(() => {})
      }
    }
  }

  build() {
    Column({ space: 24 }) {
      Button('⋯（点击菜单）')
        // ① isShow state  ② items  ③ MenuOptions (onDisappear is () => void)
        .bindMenu(
          this.showMenu,
          [
            { value: '复制', action: () => { console.log('复制') } },
            { value: '转发', action: () => { console.log('转发') } },
            { value: '删除', action: () => { console.log('删除') } }
          ],
          {
            onDisappear: () => { this.showMenu = false } // reset so it can reopen
          }
        )
        .onClick(() => { this.showMenu = true })

      Text('长按我试试（右键菜单）')
        .fontSize(20)
        .padding(20)
        // ① content: @Builder  ② responseType  ③ options
        .bindContextMenu(
          this.ctxMenuBuilder,
          ResponseType.LongPress,
          {}
        )
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center)
  }
}
