import { http } from '@kit.NetworkKit'
import { promptAction } from '@kit.ArkUI'
import { Post } from './model'

// http module demo: GET a post list, render with List + ForEach,
// handle loading / error states, and POST a new post.
@Entry
@Component
struct NetDemo {
  @State posts: Post[] = []
  @State loading: boolean = false
  @State errorMsg: string = ''
  // Keep the request reference so we can cancel it if the user leaves early.
  private req: http.HttpRequest | null = null

  aboutToAppear(): void {
    this.fetchPosts()        // fetch once when the page appears
  }

  // Cancel any in-flight request when the page is destroyed.
  aboutToDisappear(): void {
    if (this.req) {
      this.req.destroy()
      this.req = null
    }
  }

  // Fetch the post list with the http module.
  async fetchPosts() {
    this.loading = true
    this.errorMsg = ''
    this.req = http.createHttp()
    try {
      const resp = await this.req.request(
        'https://jsonplaceholder.typicode.com/posts',
        {
          method: http.RequestMethod.GET,
          connectTimeout: 10000,  // connection timeout (ms)
          readTimeout: 10000      // read timeout (ms)
        }
      )
      if (resp.responseCode === 200) {
        // By default result is a string; parse it manually.
        const data = JSON.parse(resp.result as string) as Post[]
        this.posts = data          // put it into @State, UI refreshes automatically
      } else {
        this.errorMsg = `Request failed, code=${resp.responseCode}`
      }
    } catch (err) {
      this.errorMsg = `Network error: ${(err as Error).message}`
    } finally {
      // Release when done to avoid resource leaks.
      if (this.req) {
        this.req.destroy()
        this.req = null
      }
      this.loading = false
    }
  }

  // POST a new post; send JSON in extraData with the proper Content-Type header.
  async submitPost() {
    const req = http.createHttp()
    try {
      const resp = await req.request(
        'https://jsonplaceholder.typicode.com/posts',
        {
          method: http.RequestMethod.POST,
          extraData: JSON.stringify({ title: '新标题', body: '正文内容', userId: 1 }),
          header: { 'Content-Type': 'application/json' },
          connectTimeout: 10000,
          readTimeout: 10000
        }
      )
      if (resp.responseCode === 201) {   // 201 = Created
        const created = JSON.parse(resp.result as string) as Post
        promptAction.showToast({ message: `创建成功，id=${created.id}` })
      } else {
        promptAction.showToast({ message: `提交失败，code=${resp.responseCode}` })
      }
    } catch (err) {
      promptAction.showToast({ message: `网络错误：${(err as Error).message}` })
    } finally {
      req.destroy()
    }
  }

  build() {
    Column({ space: 12 }) {
      // Top bar: title + refresh button
      Row() {
        Text('最新文章').fontSize(22).fontWeight(FontWeight.Bold)
        Blank()
        Button('刷新').onClick(() => this.fetchPosts())
      }
      .width('100%')
      .padding(16)

      Button('提交测试 (POST)').onClick(() => this.submitPost())

      // Three states: loading / error / normal list
      if (this.loading) {
        LoadingProgress().width(36).height(36)
        Text('加载中…').fontColor('#999')
      } else if (this.errorMsg) {
        Text(this.errorMsg).fontColor(Color.Red)
        Button('重试').onClick(() => this.fetchPosts())
      } else {
        List({ space: 12 }) {
          ForEach(this.posts, (item: Post) => {
            ListItem() {
              Column({ space: 6 }) {
                Text(item.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                Text(item.body)
                  .fontSize(13)
                  .fontColor('#666')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
            }
          }, (item: Post) => item.id.toString())   // use the unique id as the key
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
