import { router } from '@kit.ArkUI'

// Chapter 19 landing page: dialogs & menus.
@Entry
@Component
struct Ch19Index {
  build() {
    Column({ space: 16 }) {
      Text('第19篇：弹窗与菜单')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('要用户"做决定"用弹窗，要"选操作"用菜单')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('AlertDialog / ActionSheet')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch19/AlertAction' }))

      Button('CustomDialog（自定义弹窗 + 回传）')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch19/CustomDialog' }))

      Button('bindPopup（组件气泡）')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch19/Popup' }))

      Button('bindMenu / bindContextMenu（菜单）')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch19/Menu' }))

      Button('Picker 选择器弹窗')
        .width('85%')
        .onClick(() => router.pushUrl({ url: 'pages/ch19/Picker' }))

      Button('返回首页')
        .width('85%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
