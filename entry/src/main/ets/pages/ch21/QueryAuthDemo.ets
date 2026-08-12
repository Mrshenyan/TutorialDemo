import { http } from '@kit.NetworkKit'
import { promptAction } from '@kit.ArkUI'

// Section 5 of Chapter 21: query parameters (pagination) and auth header (Bearer token).
// Neither introduces a new API — they only change the URL and the request headers.
@Entry
@Component
struct QueryAuthDemo {
  @State info: string = '点击按钮发起带参数 / 带鉴权的请求'

  // GET with query parameters (pagination / filtering): append ?key=value to the URL.
  async getWithQuery() {
    const page = 1
    const size = 10
    const url = `https://jsonplaceholder.typicode.com/posts?page=${page}&size=${size}`
    const req = http.createHttp()
    try {
      const resp = await req.request(url, { method: http.RequestMethod.GET })
      if (resp.responseCode === 200) {
        const list = JSON.parse(resp.result as string) as Array<object>
        this.info = `查询参数请求成功，返回 ${list.length} 条 (page=${page}&size=${size})`
      } else {
        this.info = `请求失败，code=${resp.responseCode}`
      }
    } catch (err) {
      this.info = `网络错误：${(err as Error).message}`
    } finally {
      req.destroy()
    }
  }

  // GET with a Bearer auth header. Token would normally come from a login response,
  // stored safely (Preferences, covered in a later chapter).
  async getWithAuth() {
    const token = 'your_login_token_here'
    const req = http.createHttp()
    try {
      const resp = await req.request(
        'https://jsonplaceholder.typicode.com/posts',
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + token   // attach the login token
          }
        }
      )
      this.info = `鉴权请求完成，statusCode=${resp.responseCode}（真实接口需有效 token）`
    } catch (err) {
      this.info = `网络错误：${(err as Error).message}`
    } finally {
      req.destroy()
    }
  }

  build() {
    Column({ space: 16 }) {
      Text('查询参数 & 鉴权 Header')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin(16)

      Button('带查询参数 GET (?page=1&size=10)')
        .width('90%')
        .onClick(() => this.getWithQuery())

      Button('带 Bearer 鉴权 GET')
        .width('90%')
        .onClick(() => this.getWithAuth())

      Text(this.info)
        .fontSize(14)
        .fontColor('#666')
        .padding(16)
    }
    .width('100%')
    .height('100%')
  }
}
