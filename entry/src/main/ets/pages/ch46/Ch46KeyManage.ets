import { router } from '@kit.ArkUI'
import { huks } from '@kit.UniversalKeystoreKit'
import { Ch46KeyStore } from '../../ch46data/Ch46KeyStore'

interface BizErr { code: number; message: string }

// Chapter 46 demo 1 - key lifecycle.
// The whole point of HUKS: you never see the key. You get an alias, you ask
// the secure hardware to use it. Generate here, encrypt/decrypt on the next
// page, delete when done - the key itself never enters the JS heap.
@Entry
@Component
struct Ch46KeyManage {
  @State output: string = '先点「生成密钥」——密钥活在安全硬件里，App 拿不到它'
  @State exists: boolean = false
  @State aliases: string[] = []

  aboutToAppear(): void {
    this.refresh()
  }

  private refresh(): void {
    Ch46KeyStore.exists()
      .then((ok: boolean) => {
        this.exists = ok
        this.output = ok ? `密钥 ${Ch46KeyStore.alias()} 已存在` : '还没有密钥，点「生成密钥」'
      })
      .catch(() => {
        // The emulator's soft-TEE can throw 12000011 after a delete attempt -
        // keep the demo readable instead of surfacing a raw, misleading error.
        this.output = '状态查询暂不可用（模拟器 TEE 软实现限制，真机正常）'
      })
    Ch46KeyStore.listAliases()
      .then((list: string[]) => {
        this.aliases = list
      })
      .catch(() => {
        this.aliases = []
      })
  }

  private generate(): void {
    Ch46KeyStore.generate()
      .then(() => {
        this.output = '生成成功：AES-256 / CBC / 加密+解密'
        this.refresh()
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.output = `生成失败 [${be.code}] ${be.message}`
      })
  }

  private remove(): void {
    Ch46KeyStore.remove()
      .then(() => {
        this.output = '已删除。删的是安全硬件里的条目，不是文件'
        this.refresh()
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.output = `删除失败 [${be.code}] ${be.message}`
      })
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('① 密钥生命周期：生成 / 查询 / 列举 / 删除')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 12 })

        Text('HUKS 的核心人设：密钥不进 JS 堆。你拿到的是 alias（字符串），做加密时要系统把数据送进安全硬件算完再拿出来。生成、查询、列举、删除，全程摸不到密钥本体。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        Row({ space: 8 }) {
          Button('生成密钥')
            .layoutWeight(1)
            .backgroundColor('#2E7D32')
            .onClick(() => this.generate())
          Button('删除密钥')
            .layoutWeight(1)
            .backgroundColor('#C5221F')
            .onClick(() => this.remove())
          Button('刷新状态')
            .layoutWeight(1)
            .onClick(() => this.refresh())
        }
        .width('100%')

        Text(`别名：${Ch46KeyStore.alias()}`)
          .fontSize(12)
          .fontFamily('monospace')
          .width('100%')
          .padding(8)
          .backgroundColor('#F5F7F9')
          .borderRadius(6)
          .copyOption(CopyOptions.InApp)

        Text(`当前状态：${this.exists ? '密钥已存在 ✓' : '密钥不存在'}`)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .width('100%')

        Text(`密钥库里共有 ${this.aliases.length} 个密钥：`)
          .fontSize(13)
          .width('100%')

        if (this.aliases.length === 0) {
          Text('（空，或读取失败）')
            .fontSize(12)
            .fontColor('#888')
            .width('100%')
        } else {
          ForEach(this.aliases, (a: string) => {
            Text(a)
              .fontSize(12)
              .fontFamily('monospace')
              .width('100%')
              .padding(6)
              .backgroundColor('#F5F7F9')
              .borderRadius(4)
          }, (a: string) => a)
        }

        Text(this.output)
          .fontSize(12)
          .fontColor('#317af7')
          .width('100%')
          .padding(8)
          .backgroundColor('#EEF4FF')
          .borderRadius(6)

        Text('密钥蓝图（生成时写死，后面每次使用都要和它对上）：')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ top: 6 })

        Text('算法 AES-256 · 用途 加密+解密 · 分组 CBC · 填充 NONE · 摘要 NONE')
          .fontSize(12)
          .fontColor('#555')
          .width('100%')
          .padding(8)
          .backgroundColor('#F5F7F9')
          .borderRadius(6)

        Text('⚠️ 环境提醒：HUKS 依赖安全硬件（TEE），本地模拟器大概率不支持。若「生成密钥」报无能力错误，换真机验证——这是本篇和前面所有章节最大的环境差异。')
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
