import { router } from '@kit.ArkUI'

// All tutorial chapters. Append a new entry here whenever a chapter sub-package is added.
interface Chapter {
  title: string
  desc: string
  url: string
}

@Entry
@Component
struct Index {
  // The main project is a list of tutorials; each item jumps to that tutorial's page.
  private chapters: Chapter[] = [
    {
      title: '第15篇：Observed 与 ObjectLink',
      desc: '嵌套对象的深层属性如何驱动 UI 刷新',
      url: 'pages/ch15/Index'
    },
    {
      title: '第16篇：ForEach 与 LazyForEach',
      desc: '列表渲染：中小列表与长列表懒加载',
      url: 'pages/ch16/Index'
    },
    {
      title: '第17篇：Navigation 页面导航',
      desc: 'NavPathStack + NavDestination 取代老 Router',
      url: 'pages/ch17/Index'
    },
    {
      title: '第18篇：Tabs 底部导航栏',
      desc: 'App 外壳：图标 / 角标 / 独立栈',
      url: 'pages/ch18/Index'
    },
    {
      title: '第19篇：弹窗与菜单',
      desc: 'AlertDialog / CustomDialog / 菜单浮层',
      url: 'pages/ch19/Index'
    },
    {
      title: '第20篇：动画与转场',
      desc: 'animation / transition / 共享元素 / 页面转场',
      url: 'pages/ch20/Index'
    },
    {
      title: '第21篇：网络数据请求',
      desc: 'http 模块 与 RCP 两套请求方式',
      url: 'pages/ch21/Index'
    },
    {
      title: '第22篇：数据持久化 Preferences',
      desc: '轻量级 KV 存储：增删改查与变更订阅',
      url: 'pages/ch22/Index'
    }
  ]

  build() {
    Column() {
      Text('鸿蒙零基础教程 · Demo 合集')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 16 })

      List({ space: 12 }) {
        ForEach(this.chapters, (c: Chapter) => {
          ListItem() {
            Row() {
              Column({ space: 4 }) {
                Text(c.title).fontSize(18).fontWeight(FontWeight.Medium)
                Text(c.desc).fontSize(13).fontColor('#666')
              }
              Blank()
              Text('>').fontSize(18).fontColor('#999')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onClick(() => router.pushUrl({ url: c.url }))
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
  }
}
