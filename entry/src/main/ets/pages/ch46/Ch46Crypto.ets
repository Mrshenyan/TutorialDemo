import { router } from '@kit.ArkUI'
import { huks } from '@kit.UniversalKeystoreKit'
import { cryptoFramework } from '@kit.CryptoArchitectureKit'
import { util } from '@kit.ArkTS'
import { Ch46KeyStore } from '../../ch46data/Ch46KeyStore'

interface BizErr { code: number; message: string }

// Chapter 46 demo 2 - AES-256-CBC round trip through HUKS.
//
// The full chain, with nothing hidden:
//   text -> PKCS7 pad to 16B -> random IV -> HUKS encrypt -> hex
//   hex -> bytes -> same IV -> HUKS decrypt -> unpad -> text
//
// Three things this demo deliberately shows instead of hiding:
//   1. HUKS has NO PKCS7 padding, so the app owns block alignment. Skipping
//      this is the #1 beginner bug: "why does it only work on 16-char input".
//   2. CBC needs an IV. It is not secret - prepend it to the ciphertext. What
//      IS fatal is reusing the IV with the same key, or losing it.
//   3. The key never appears anywhere in this file. That is the point.
@Entry
@Component
struct Ch46Crypto {
  @State input: string = '跟着cc一起学鸿蒙开发46'
  @State cipherHex: string = '（先点「加密」）'
  @State roundTrip: string = '（再点「解密」验证）'
  @State log: string = '还没有操作'

  // Held in memory only. Real apps store IV+ciphertext to a file or the
  // network; the key stays in HUKS forever.
  private iv: Uint8Array = new Uint8Array(0)
  private cipher: Uint8Array = new Uint8Array(0)

  private toHex(bytes: Uint8Array): string {
    const hex: string[] = []
    for (let i = 0; i < bytes.length; i++) {
      const b: number = bytes[i]
      hex.push((b < 16 ? '0' : '') + b.toString(16))
    }
    return hex.join('')
  }

  private fromHex(s: string): Uint8Array {
    const clean: string = s.replace(/\s/g, '')
    const out: Uint8Array = new Uint8Array(clean.length / 2)
    for (let i = 0; i < out.length; i++) {
      out[i] = parseInt(clean.substr(i * 2, 2), 16)
    }
    return out
  }

  // PKCS7 pad to a 16-byte boundary. A full block short -> append a whole
  // block of 0x10, otherwise the unpad step cannot tell real padding from data.
  private pkcs7Pad(bytes: Uint8Array): Uint8Array {
    const padLen: number = 16 - (bytes.length % 16)
    const out: Uint8Array = new Uint8Array(bytes.length + padLen)
    out.set(bytes)
    for (let i = 0; i < padLen; i++) {
      out[bytes.length + i] = padLen
    }
    return out
  }

  private pkcs7Unpad(bytes: Uint8Array): Uint8Array {
    if (bytes.length === 0) {
      return bytes
    }
    const padLen: number = bytes[bytes.length - 1]
    if (padLen < 1 || padLen > 16 || padLen > bytes.length) {
      return bytes
    }
    return bytes.subarray(0, bytes.length - padLen)
  }

  private randomIv(): Uint8Array {
    // System-grade randomness. Math.random() is NOT acceptable for crypto.
    const rand: cryptoFramework.Random = cryptoFramework.createRandom()
    const blob: cryptoFramework.DataBlob = rand.generateRandomSync(16)
    return blob.data
  }

  private encrypt(): void {
    const enc: util.TextEncoder = new util.TextEncoder()
    // ArkTS TextEncoder.encode() is synchronous and returns Uint8Array directly.
    // (encodeInto exists too but is async; encode is the simplest correct path.)
    const raw: Uint8Array = enc.encode(this.input)
    const padded: Uint8Array = this.pkcs7Pad(raw)
    this.iv = this.randomIv()
    Ch46KeyStore.runCipher(true, this.iv, padded)
      .then((out: Uint8Array) => {
        this.cipher = out
        this.cipherHex = this.toHex(out)
        this.roundTrip = '（点「解密」验证）'
        this.log = `加密成功：${padded.length}B 明文 → ${out.length}B 密文，IV=${this.toHex(this.iv).slice(0, 16)}…`
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.log = `加密失败 [${be.code}] ${be.message}`
      })
  }

  private decrypt(): void {
    if (this.cipher.length === 0) {
      this.log = '先点「加密」'
      return
    }
    Ch46KeyStore.runCipher(false, this.iv, this.cipher)
      .then((out: Uint8Array) => {
        const unpadded: Uint8Array = this.pkcs7Unpad(out)
        const dec: util.TextDecoder = new util.TextDecoder()
        const text: string = dec.decodeToString(unpadded)
        this.roundTrip = text
        this.log = `解密成功：${out.length}B 密文 → ${unpadded.length}B 明文`
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        this.log = `解密失败 [${be.code}] ${be.message}`
      })
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('② AES-256-CBC：过一遍安全硬件')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 12 })

        Text('明文在 App 里补位，密文在安全硬件里产生，密钥全程不可见。加密后 IV 和密文拼一起保存——IV 不机密，丢了它才机密（永远解不开）。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        TextInput({ text: this.input })
          .width('100%')
          .onChange((v: string) => this.input = v)

        Row({ space: 8 }) {
          Button('加密')
            .layoutWeight(1)
            .backgroundColor('#6A1B9A')
            .onClick(() => this.encrypt())
          Button('解密')
            .layoutWeight(1)
            .backgroundColor('#00838F')
            .onClick(() => this.decrypt())
        }
        .width('100%')

        Text(`密文（hex）：${this.cipherHex}`)
          .fontSize(11)
          .fontFamily('monospace')
          .width('100%')
          .padding(8)
          .backgroundColor('#F5F7F9')
          .borderRadius(6)

        Text(`解密回原文：${this.roundTrip}`)
          .fontSize(13)
          .width('100%')
          .padding(8)
          .backgroundColor('#E8F5E9')
          .borderRadius(6)

        Text(this.log)
          .fontSize(12)
          .fontColor('#317af7')
          .width('100%')
          .padding(8)
          .backgroundColor('#EEF4FF')
          .borderRadius(6)

        Text('流程拆解（对应 Ch46KeyStore.runCipher）：')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ top: 6 })

        Text('① PKCS7 补位到 16 倍数 —— HUKS 没有 PKCS7，补位是 App 的活，忘这条会莫名其妙加密失败')
          .fontSize(12)
          .fontColor('#555')
          .width('100%')

        Text('② cryptoFramework 生成 16B 随机 IV —— 加密随机性必须用系统随机源，Math.random 在密码学里等于没随机')
          .fontSize(12)
          .fontColor('#555')
          .width('100%')

        Text('③ initSession(alias, { properties, inData: 明文 }) → finishSession(handle, { properties }) → 密文 —— 密钥在安全硬件里，JS 侧只见数据')
          .fontSize(12)
          .fontColor('#555')
          .width('100%')

        Text('④ 失败必须 abortSession —— 会话句柄是按算法限量的（个位数），泄漏一次就少一个，攒满之后全工程加密全挂')
          .fontSize(12)
          .fontColor('#B26A00')
          .width('100%')

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
