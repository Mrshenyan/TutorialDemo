import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'

/**
 * RCP basic demo: GET with session.get() and POST with session.fetch(new Request).
 *
 * Prerequisites (must be declared in module.json5):
 *   "requestPermissions": [{ "name": "ohos.permission.INTERNET" }]
 *
 * Common error codes:
 *   201        -> INTERNET permission missing (add it to module.json5)
 *   10200002   -> invalid URL string (check the address format)
 */
@Entry
@Component
struct Ch36RcpBasicDemo {
  @State getResult: string = '点击「GET」发起请求'
  @State postResult: string = '点击「POST」发起请求'

  // GET: the simplest form. session.get(url) returns a Promise<Response>.
  async doGet(): Promise<void> {
    const session: rcp.Session = rcp.createSession()
    try {
      const response: rcp.Response = await session.get('https://www.example.com')
      this.getResult = `statusCode=${response.statusCode}\nbody=${response}`
    } catch (err) {
      const e: BusinessError = err as BusinessError
      this.getResult = `GET failed: code=${e.code}, msg=${e.message}`
    } finally {
      // Always close the session to release the underlying connection.
      session.close()
    }
  }

  // POST: build a Request so we can set the content-type header and body.
  async doPost(): Promise<void> {
    const session: rcp.Session = rcp.createSession()
    const payload: string = JSON.stringify({ title: 'hello', body: 'from rcp', userId: 1 })

    let req: rcp.Request = new rcp.Request('https://jsonplaceholder.typicode.com/posts', 'POST')
    let headers: Record<string, string> = { 'content-type': 'application/json' }
    req.headers = headers
    req.content = payload

    try {
      const response: rcp.Response = await session.fetch(req)
      this.postResult = `statusCode=${response.statusCode}\n${response}`
    } catch (err) {
      const e: BusinessError = err as BusinessError
      this.postResult = `POST failed: code=${e.code}, msg=${e.message}`
    } finally {
      session.close()
    }
  }

  build() {
    Column({ space: 16 }) {
      Text('RCP 基础请求').fontSize(22).fontWeight(FontWeight.Bold)

      Button('GET  https://www.example.com')
        .width('90%')
        .onClick(() => { this.doGet() })

      Text(this.getResult)
        .width('90%')
        .fontSize(12)
        .fontFamily('monospace')

      Button('POST  jsonplaceholder')
        .width('90%')
        .onClick(() => { this.doPost() })

      Text(this.postResult)
        .width('90%')
        .fontSize(12)
        .fontFamily('monospace')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Start)
  }
}
