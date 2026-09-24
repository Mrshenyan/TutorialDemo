import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'

/**
 * RCP advanced demo: timeout, resumable download (transferRange) and SSL certificate pinning.
 *
 * 1. Timeout: request.configuration.transfer.timeout = { connectMs, transferMs }
 * 2. Resume:  request.transferRange = { from, to }  (server must support HTTP Range)
 * 3. Pinning: request.configuration.security.certificatePinning = [{ kind, publicKeyHash, hashAlgorithm }]
 *    Only trust a server whose certificate public-key SHA-256 matches the value. Suitable for
 *    finance/banking apps. Always keep at least one backup key and consider an expiration.
 */
@Entry
@Component
struct Ch36RcpAdvancedDemo {
  @State log: string = '点击按钮体验高级配置'

  // Timeout + resumable download of the first 1 MB.
  async doResumeDownload(): Promise<void> {
    const session: rcp.Session = rcp.createSession()
    let req: rcp.Request = new rcp.Request('https://www.example.com/large.bin', 'GET')
    req.configuration = {
      transfer: {
        timeout: { connectMs: 5000, transferMs: 30000 }
      }
    }
    req.transferRange = { from: 0, to: 1024 * 1024 }
    try {
      const response: rcp.Response = await session.fetch(req)
      if(response){
        this.log = `statusCode=${response.statusCode}, received ${response} bytes`
      }
    } catch (err) {
      const e: BusinessError = err as BusinessError
      this.log = `err=${e.code}:${e.message}`
    } finally {
      session.close()
    }
  }

  // SSL certificate pinning: only accept the pinned public key (replace with your real hash).
  async doCertPinning(): Promise<void> {
    const session: rcp.Session = rcp.createSession()
    let req: rcp.Request = new rcp.Request('https://www.example.com', 'GET')
    let pin: rcp.CertificatePinning = {
      kind: 'public-key',
      publicKeyHash: 'REPLACE_WITH_SERVER_PUBLIC_KEY_SHA256_BASE64==',
      hashAlgorithm: 'SHA-256'
    }
    req.configuration = { security: { certificatePinning: pin } }
    try {
      const response: rcp.Response = await session.fetch(req)
      this.log = `pinned request ok: ${response.statusCode}`
    } catch (err) {
      const e: BusinessError = err as BusinessError
      this.log = `pinning err=${e.code}:${e.message}`
    } finally {
      session.close()
    }
  }

  build() {
    Column({ space: 16 }) {
      Text('RCP 高级配置').fontSize(22).fontWeight(FontWeight.Bold)

      Button('超时 + 断点续传（前 1MB）')
        .width('90%')
        .onClick(() => { this.doResumeDownload() })

      Button('SSL 证书锁定')
        .width('90%')
        .onClick(() => { this.doCertPinning() })

      Text(this.log)
        .width('90%')
        .fontSize(13)
        .fontFamily('monospace')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Start)
  }
}
