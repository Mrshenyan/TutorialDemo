// Chapter 19 §二-§三: AlertDialog (confirm) + ActionSheet (a row of actions).
// Both are static .show() methods — no new, no controller.

@Entry
@Component
struct AlertAction {
  @State count: number = 0

  build() {
    Column({ space: 16 }) {
      Text(`当前数量：${this.count}`).fontSize(20)

      Button('删除一项（AlertDialog）')
        .onClick(() => {
          AlertDialog.show({
            title: '确认删除',
            subtitle: '此操作不可恢复',
            message: '删除后数据将无法找回，确定吗？',
            autoCancel: true,
            alignment: DialogAlignment.Center,
            primaryButton: {
              value: '取消',
              action: () => { console.log('用户取消了') }
            },
            secondaryButton: {
              value: '删除',
              fontColor: '#E8380D',
              action: () => { this.count += 1 }
            },
            // Intercept dismissal: not calling action.dismiss() keeps it open.
            onWillDismiss: (action: DismissDialogAction) => {
              if (action.reason === DismissReason.PRESS_BACK) {
                action.dismiss()
              }
            }
          })
        })

      Button('分享（ActionSheet）')
        .onClick(() => {
          ActionSheet.show({
            title: '分享到',
            message: '选择分享方式',
            autoCancel: true,
            confirm: {
              value: '取消',
              action: () => {}
            },
            cancel: () => { console.log('用户点了取消/遮罩') },
            sheets: [
              { title: '微信好友', action: () => { console.log('分享到微信') } },
              { title: '朋友圈', action: () => { console.log('分享到朋友圈') } },
              { title: '复制链接', action: () => { console.log('已复制') } }
            ]
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
