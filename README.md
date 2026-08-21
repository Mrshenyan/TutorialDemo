# TutorialDemo · 跟着 cc 一起学鸿蒙开发

> 鸿蒙小白教程《跟着 cc 一起学鸿蒙开发》官方配套 Demo 工程
> 一个工程、27 篇教程、91 个可运行页面：从 Hello World 到分布式开发，全流程示例。

## 项目简介

本仓库是微信公众号**【Cocoser】**的「跟着 cc 一起学鸿蒙开发」系列教程的配套源码，全部使用 **HarmonyOS 原生 ArkTS / ArkUI**（Stage 模型）编写，覆盖鸿蒙开发从入门到进阶的完整路径：

- **语言与框架基础**：ArkTS、声明式 UI、自定义组件、@Builder / @Styles / @Extend 复用体系
- **状态管理全家族**：@State / @Prop / @Link / @Provide / @Consume / @Observed / @ObjectLink / AppStorage / LocalStorage / Environment
- **系统能力实战**：网络请求（http + RCP）、数据持久化 Preferences、关系型数据库 RelationalStore、分布式 KV Store
- **性能与体验**：DevEco Profiler 性能调优、动画与转场、手势识别与 Canvas 绘图

所有代码**开箱即运行**（API 22 / SDK 6.0.2）。每章一个独立子包 `pages/chNN/`，App 首页用列表聚合全部章节，一键跳转。

## 章节目录

| 篇 | 主题 | 内容要点 | 源码 |
|---|---|---|---|
| 第 1 篇 | Hello World 与工程结构 | Empty Ability + Stage 模型，跑通第一个 Hello World | [ch01](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch01) |
| 第 2 篇 | 工程结构速览 | AppScope / entry / main_pages / module.json5 职责划分 | [ch02](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch02) |
| 第 3 篇 | Stage 模型核心概念 | AbilityStage / UIAbility / WindowStage / Context 与生命周期 | [ch03](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch03) |
| 第 4 篇 | ArkTS 语言与声明式 UI | 声明式描述 UI：组件创建、属性方法、事件方法 | [ch04](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch04) |
| 第 5 篇 | 自定义组件与基础语法 | @Component / @Entry、组件生命周期、条件渲染 | [ch05](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch05) |
| 第 6 篇 | @Builder 自定义构建函数 | 成员 Builder / 全局 Builder / 值传递 vs 引用传递 | [ch06](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch06) |
| 第 7 篇 | @BuilderParam 构建参数 | 把构建函数当参数传入子组件（插槽 / 尾随闭包） | [ch07](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch07) |
| 第 8 篇 | @Styles 样式复用 | 全局 / 组件内样式，组件内优先级更高 | [ch08](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch08) |
| 第 9 篇 | stateStyles 动态样式 | 按 focused / pressed / normal / disabled 切换样式 | [ch09](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch09) |
| 第 10 篇 | @Extend 扩展组件样式 | 仅全局、针对具体组件类型、可封装私有属性与事件 | [ch10](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch10) |
| 第 11 篇 | 状态管理入门 | @State 状态变量变化驱动 UI 刷新；普通变量不会 | [ch11](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch11) |
| 第 12 篇 | @State 装饰器 | 私有数据源、简单类型直接观察、对象属性亦可 | [ch12](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch12) |
| 第 13 篇 | @Prop 与 @Link | Prop 父子单向 / Link 父子双向（传 `$` 引用） | [ch13](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch13) |
| 第 14 篇 | @Provide 与 @Consume | 跨层级双向同步，按变量名 / 别名自动配对 | [ch14](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch14) |
| 第 15 篇 | @Observed 与 @ObjectLink | 嵌套对象的深层属性如何驱动 UI 刷新 | [ch15](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch15) |
| 第 16 篇 | ForEach 与 LazyForEach | 列表渲染：中小列表与长列表懒加载、@Reusable 复用 | [ch16](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch16) |
| 第 17 篇 | Navigation 页面导航 | NavPathStack + NavDestination 取代老 Router，返回拦截 | [ch17](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch17) |
| 第 18 篇 | Tabs 底部导航栏 | App 外壳：图标 / 角标 / 独立栈 | [ch18](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch18) |
| 第 19 篇 | 弹窗与菜单 | AlertDialog / CustomDialog / 菜单 / Popup / Picker | [ch19](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch19) |
| 第 20 篇 | 动画与转场 | animation / transition / 共享元素 / 页面转场 | [ch20](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch20) |
| 第 21 篇 | 网络数据请求 | http 模块 与 RCP 两套请求方式、权限申请 | [ch21](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch21) |
| 第 22 篇 | 数据持久化 Preferences | 轻量级 KV 存储：增删改查与变更订阅 | [ch22](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch22) |
| 第 23 篇 | 性能调优 Profiler | 6 个可复现场景：Launch / Frame / ArkUI / Time / Allocation / Snapshot | [ch23](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch23) |
| 第 24 篇 | 本地数据库 RelationalStore | 建库建表 / 增删改查 / 谓词 / 事务（记账本实战） | [ch24](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch24) |
| 第 25 篇 | 应用级状态管理 | AppStorage 全局 / LocalStorage 页面级 / Environment 设备环境 | [ch25](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch25) |
| 第 26 篇 | 分布式 KV Store | 单设备 KV 三步走 + 跨设备自动同步（鸿蒙分布式特色） | [ch26](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch26) |
| 第 27 篇 | 手势识别与 Canvas 绘图 | Canvas 画板 + 手指签名：onTouch / PanGesture + 保存到相册 | [ch27](https://github.com/Mrshenyan/TutorialDemo/tree/main/entry/src/main/ets/pages/ch27) |

## 工程结构

```
TutorialDemo/
├── AppScope/                     # 应用全局配置（app.json5、图标资源）
├── entry/
│   └── src/main/
│       ├── ets/pages/            # 全部章节源码（ch01 ~ ch27）
│       ├── resources/            # 资源与路由表 main_pages.json（91 个页面）
│       └── module.json5          # 模块配置与权限声明
├── .github/workflows/            # GitHub Actions 自动编译打包
├── Jenkinsfile                   # Jenkins 流水线
└── qrcode.jpg                    # 公众号二维码
```

- 包名：`com.cc.tutorialdemo`，API 基线：`compatibleSdkVersion 22`（SDK 6.0.2）
- 新增章节：追加 `pages/chNN/` 子包 → 首页 `Index.ets` 的 `chapters` 数组加一项 → `main_pages.json` 注册路由

## 快速开始

1. `git clone https://github.com/Mrshenyan/TutorialDemo.git`
2. 用 **DevEco Studio**（建议 5.0+，SDK 6.0.2(22)）打开工程
3. 等待 Sync 完成，连接模拟器或真机（API 22+）后直接 Run
4. 首页列表即全部章节入口，点击跳转对应 Demo

[MIT](LICENSE)

---

![qrcode.jpg](qrcode.jpg)

扫码关注公众号**【Cocoser】**同步获取每篇教程的推文讲解。
