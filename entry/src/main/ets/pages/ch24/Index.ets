import { router } from '@kit.ArkUI';

// Chapter 24 landing page: links to the three RelationalStore demos.
@Entry
@Component
struct Ch24Index {
  build() {
    Column({ space: 16 }) {
      Text('第24篇：本地数据库 RelationalStore')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('本章 demo：关系型数据库建库建表 / 增删改查 / 谓词 / 事务（个人记账本实战）')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 16 })

      Button('记账本：列表 / 筛选 / 增删改')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch24/BillListDemo' } as router.RouterOptions))

      Button('记账本：新增 / 编辑页')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch24/BillEditDemo' } as router.RouterOptions))

      Button('谓词查询 RdbPredicates 专项')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch24/PredicateDemo' } as router.RouterOptions))

      Button('返回首页')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }


}
