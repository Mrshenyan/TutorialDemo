import { router } from '@kit.ArkUI'

interface InfoRow { name: string; desc: string }

// Static cheat-sheet page: lifecycle, the three refresh paths, and the component
// whitelist a card can use. No logic here - it is the page readers keep open
// while writing their own widget.
@Entry
@Component
struct Ch43Lifecycle {
  private lifecycle: InfoRow[] = [
    { name: 'onAddForm(want)', desc: '卡片被加到桌面。必须同步返回 FormBindingData，返回 Promise 等于没返回' },
    { name: 'onUpdateForm(formId)', desc: '定时/定点刷新到点。框架只叫你，不替你渲染，要自己调 updateForm' },
    { name: 'onFormEvent(formId, msg)', desc: '卡片里 postCardAction({action:"message"}) 触发，msg 是 params 的 JSON 字符串' },
    { name: 'onRemoveForm(formId)', desc: '用户删掉卡片。formId 失效，别在里面删数据' },
    { name: 'onAcquireFormState(want)', desc: '桌面问「这张卡能不能显示」，返回 READY 才会渲染' }
  ]

  private refreshWays: InfoRow[] = [
    { name: '定时刷新', desc: 'form_config.json 里 updateEnabled:true + updateDuration:N，单位 30 分钟，N=2 即 1 小时' },
    { name: '定点刷新', desc: 'formProvider.setFormNextRefreshTime(formId, minute)，最短 5 分钟，一次生效' },
    { name: '主动推送', desc: 'formProvider.updateForm(formId, data)，App 里改了数据立刻推给桌面' }
  ]

  private forbidden: string[] = [
    'Swiper / Tabs / Scroll / Grid / List 以外的容器（List 可用，滚动类不行）',
    'Web / Video / XComponent / Canvas 之外的绘制能力',
    'router.pushUrl、Navigation 跳转（要用 postCardAction 的 router 事件）',
    '直接读写文件、拉起其他 Ability、长期后台任务',
    '自定义动画 animateTo / transition（卡片是快照渲染）'
  ]

  @Builder
  infoRow(item: InfoRow) {
    Column({ space: 4 }) {
      Text(item.name)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1B1F27')
        .width('100%')
      Text(item.desc)
        .fontSize(12)
        .fontColor('#555')
        .width('100%')
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#F5F7F9')
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Text('第43篇：卡片生命周期与刷新机制')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 12 })

        Text('① 五个生命周期')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('100%')
          .margin({ top: 6 })

        ForEach(this.lifecycle, (item: InfoRow) => {
          this.infoRow(item)
        }, (item: InfoRow) => item.name)

        Text('② 三种刷新方式')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('100%')
          .margin({ top: 10 })

        ForEach(this.refreshWays, (item: InfoRow) => {
          this.infoRow(item)
        }, (item: InfoRow) => item.name)

        Text('配额：每张卡片每天通过「定时 + 定点」触发刷新的总次数上限 50 次，0 点重置。updateDuration 优先级高于 scheduledUpdateTime，两个都配只有前者生效。')
          .fontSize(12)
          .fontColor('#B26A00')
          .width('100%')
          .padding(10)
          .backgroundColor('#FFF8E5')
          .borderRadius(8)

        Text('③ 卡片里不能用的东西')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('100%')
          .margin({ top: 10 })

        ForEach(this.forbidden, (line: string, idx: number) => {
          Text(`· ${line}`)
            .fontSize(12)
            .fontColor('#555')
            .width('100%')
            .padding({ left: 4, top: 2, bottom: 2 })
        }, (line: string, idx: number) => `${idx}_${line}`)

        Text('④ 数据通道')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('100%')
          .margin({ top: 10 })

        Text('FormExtensionAbility.onAddForm() 返回的 FormBindingData 会被写进卡片的 LocalStorage，卡片里用 @LocalStorageProp(\'key\') 取。key 对不上就是永远拿默认值，这是「卡片一片空白」最常见的原因。')
          .fontSize(12)
          .fontColor('#555')
          .width('100%')

        Text('注意：卡片和 App 很可能是两个进程。内存里共享变量、单例、AppStorage 都跨不过去，能跨的只有 preferences / 数据库这类落盘数据 + updateForm 主动推送。')
          .fontSize(12)
          .fontColor('#B26A00')
          .width('100%')
          .padding(10)
          .backgroundColor('#FFF8E5')
          .borderRadius(8)

        Button('返回')
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => router.back())
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
  }
}
