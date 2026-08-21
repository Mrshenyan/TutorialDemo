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
      title: '第1篇：Hello World 与工程结构',
      desc: 'Empty Ability + Stage 模型，跑通第一个 Hello World',
      url: 'pages/ch01/Index'
    },
    {
      title: '第2篇：工程结构速览',
      desc: 'AppScope / entry / main_pages / module.json5 职责',
      url: 'pages/ch02/Index'
    },
    {
      title: '第3篇：Stage 模型核心概念',
      desc: 'AbilityStage / UIAbility / WindowStage / Context 与生命周期',
      url: 'pages/ch03/Index'
    },
    {
      title: '第4篇：ArkTS 语言与声明式 UI',
      desc: '声明式描述 UI：组件创建、属性方法、事件方法',
      url: 'pages/ch04/Index'
    },
    {
      title: '第5篇：自定义组件与基础语法',
      desc: '@Component / @Entry / 生命周期 / 条件渲染',
      url: 'pages/ch05/Index'
    },
    {
      title: '第6篇：@Builder 自定义构建函数',
      desc: '成员 Builder / 全局 Builder / 值传递 vs 引用传递',
      url: 'pages/ch06/Index'
    },
    {
      title: '第7篇：@BuilderParam 构建参数',
      desc: '把构建函数当参数传入子组件（插槽 / 尾随闭包）',
      url: 'pages/ch07/Index'
    },
    {
      title: '第8篇：@Styles 样式复用',
      desc: '全局 / 组件内样式，组件内优先级更高',
      url: 'pages/ch08/Index'
    },
    {
      title: '第9篇：stateStyles 动态样式',
      desc: '按 focused / pressed / normal / disabled 切换样式',
      url: 'pages/ch09/Index'
    },
    {
      title: '第10篇：@Extend 扩展组件样式',
      desc: '仅全局、针对具体组件类型、可封装私有属性与事件',
      url: 'pages/ch10/Index'
    },
    {
      title: '第11篇：状态管理入门',
      desc: '@State 状态变量变化驱动 UI 刷新；普通变量不会',
      url: 'pages/ch11/Index'
    },
    {
      title: '第12篇：@State 装饰器',
      desc: '私有数据源、简单类型直接观察、对象属性亦可',
      url: 'pages/ch12/Index'
    },
    {
      title: '第13篇：@Prop 与 @Link',
      desc: 'Prop 父子单向 / Link 父子双向（传 $ 引用）',
      url: 'pages/ch13/Index'
    },
    {
      title: '第14篇：@Provide 与 @Consume',
      desc: '跨层级双向同步，按变量名 / 别名自动配对',
      url: 'pages/ch14/Index'
    },
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
    },
    {
      title: '第23篇：性能调优 Profiler（工具+实战）',
      desc: '6 个可复现场景：Launch/Frame/ArkUI/Time/Allocation/Snapshot',
      url: 'pages/ch23/Index'
    },
    {
      title: '第24篇：本地数据库 RelationalStore',
      desc: '关系型数据库：建库建表 / 增删改查 / 谓词 / 事务（记账本实战）',
      url: 'pages/ch24/Index'
    },
    {
      title: '第25篇：应用级状态管理',
      desc: 'AppStorage 全局 / LocalStorage 页面级 / Environment 设备环境',
      url: 'pages/ch25/Index'
    },
    {
      title: '第26篇：分布式 KV Store',
      desc: '单设备 KV 三步走 + 跨设备自动同步（鸿蒙分布式特色）',
      url: 'pages/ch26/Index'
    },
    {
      title: '第27篇：手势识别与 Canvas 绘图',
      desc: 'Canvas 画板 + 手指签名：onTouch / PanGesture + 保存到相册（免权限/权限双方案）',
      url: 'pages/ch27/Index'
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
