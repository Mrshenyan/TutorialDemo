// Chapter 3 demo: the four layers of the Stage model + an on-screen lifecycle trace.
@Entry
@Component
struct StageModelDemo {
  @State log: string = '等待生命周期回调...'

  // aboutToAppear runs once after the component instance is created, before build().
  aboutToAppear(): void {
    this.log = 'aboutToAppear: 组件即将出现'
  }

  // onPageShow runs when the page becomes visible (only on @Entry components).
  onPageShow(): void {
    this.log = 'onPageShow: 页面已显示'
  }

  build() {
    Column({ space: 12 }) {
      Text('Stage 模型四层')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      this.layerCard('AbilityStage', '每个 HAP 运行时的舞台，承载 HAP 的能力实现')
      this.layerCard('UIAbility', '含 UI 的组件，负责与用户交互（日常开发重点）')
      this.layerCard('WindowStage', '与 UIAbility 绑定的窗口管理，为 ArkUI 提供绘制区域')
      this.layerCard('Context', '运行期能力接口，Ability 通过它调用系统能力')

      Divider().margin({ top: 8, bottom: 8 })

      Text(this.log)
        .fontSize(14)
        .fontColor('#38761D')
        .margin(8)
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }

  @Builder layerCard(title: string, desc: string) {
    Column({ space: 4 }) {
      Text(title).fontSize(18).fontWeight(FontWeight.Medium)
      Text(desc).fontSize(13).fontColor('#666')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(12)
    .backgroundColor('#EAF2FF')
    .borderRadius(8)
  }
}
