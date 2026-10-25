import { router } from '@kit.ArkUI'

// Chapter 46 landing page: HUKS key management.
// The through-line: HUKS keeps the key, you keep the alias. Everything else
// (generate, use, delete) is alias bookkeeping.
@Entry
@Component
struct Ch46Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('第46篇：HUKS 密钥管理')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 4 })

        Text('数据库里那串「加密后」的密码，密钥放哪？放代码里等于没加密。这一篇用鸿蒙的安全硬件钥匙串（HUKS）：密钥生成、使用、删除，全程摸不到密钥本体。')
          .fontSize(13)
          .fontColor('#666')
          .width('92%')
          .margin({ bottom: 6 })

        Text('① 密钥生命周期（生成 / 查询 / 列举 / 删除）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)

        Button('密钥管理演示')
          .width('92%')
          .backgroundColor('#2E7D32')
          .onClick(() => router.pushUrl({ url: 'pages/ch46/Ch46KeyManage' } as router.RouterOptions))

        Text('② AES-256-CBC 加解密（过一遍安全硬件）')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#317af7')
          .width('92%')
          .textAlign(TextAlign.Start)
          .margin({ top: 8 })

        Button('加解密演示')
          .width('92%')
          .backgroundColor('#6A1B9A')
          .onClick(() => router.pushUrl({ url: 'pages/ch46/Ch46Crypto' } as router.RouterOptions))

        Text('环境提示：HUKS 依赖安全硬件（TEE），本地模拟器大概率不支持，报「无对应能力」时换真机。真机上密钥随硬件存在，卸载 App 不会删除硬件层密钥，需要显式 deleteKeyItem。')
          .fontSize(12)
          .fontColor('#888')
          .width('92%')
          .margin({ top: 10 })

        Button('返回首页')
          .width('92%')
          .margin({ top: 16 })
          .onClick(() => router.back())
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }
}
