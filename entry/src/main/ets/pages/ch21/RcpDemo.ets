import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'
import { Post } from './model'

// Configure the session once: base address, default header, default timeout.
// Relative URLs resolve against baseAddress; every request carries the header + timeout.
const sessionConfig: rcp.SessionConfiguration = {
  baseAddress: 'https://jsonplaceholder.typicode.com',
  headers: { 'Content-Type': 'application/json' } as rcp.RequestHeaders,
  requestConfiguration: {
    transfer: {
      timeout: { connectMs: 10000, transferMs: 10000 }   // default connect/read timeout (ms)
    }
  }
}

// RCP demo: modern remote-communication framework (API 22 official recommendation).
@Entry
@Component
struct RcpDemo {
  @State post: Post | null = null
  @State errorMsg: string = ''
  // Create the session once and reuse it (at most 16 sessions per app).
  private session: rcp.Session = rcp.createSession(sessionConfig)

  aboutToAppear(): void {
    this.loadWithRcp()
  }

  // Cancel in-flight requests, then release the session when the page is gone.
  aboutToDisappear(): void {
    this.session.cancel()   // cancel all ongoing requests in this session
    this.session.close()    // free the session resources
  }

  // GET with RCP: session.get returns a Promise<Response>.
  async loadWithRcp() {
    try {
      const response = await this.session.get('/posts/1')
      if (response.statusCode === 200) {
        // response.toJSON() parses the JSON body into an object.
        this.post = response.toJSON() as Post
      } else {
        this.errorMsg = `Request failed, code=${response.statusCode}`
      }
    } catch (err) {
      const e = err as BusinessError
      this.errorMsg = `RCP error: code=${e.code}, ${e.message}`
    }
  }

  // POST with RCP: pass the JSON string directly as the request body.
  async submitWithRcp() {
    try {
      const response = await this.session.post(
        '/posts',
        JSON.stringify({ title: 'New Title', body: 'Content', userId: 1 })
      )
      if (response.statusCode === 201) {
        const created = response.toJSON() as Post
        promptAction.showToast({ message: `Created, id=${created.id}` })
      } else {
        promptAction.showToast({ message: `Submit failed, code=${response.statusCode}` })
      }
    } catch (err) {
      const e = err as BusinessError
      promptAction.showToast({ message: `RCP error: code=${e.code}, ${e.message}` })
    }
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('RCP 演示').fontSize(22).fontWeight(FontWeight.Bold)
        Blank()
        Button('重新加载').onClick(() => this.loadWithRcp())
      }
      .width('100%')
      .padding(16)

      Button('提交测试 (POST)').onClick(() => this.submitWithRcp())

      if (this.errorMsg) {
        Text(this.errorMsg).fontColor(Color.Red).padding(16)
      } else if (this.post) {
        Column({ space: 6 }) {
          Text(this.post.title).fontSize(16).fontWeight(FontWeight.Medium)
          Text(this.post.body).fontSize(13).fontColor('#666')
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .margin(16)
      }
    }
    .width('100%')
    .height('100%')
  }
}
