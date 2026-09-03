import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

// Chapter 30 §四: intercept requests and serve local data — the offline fallback pattern.
//
// The H5 page asks for https://demo.local/avatar.png and https://api.local/notes.
// Those hosts do not exist, so without interception every request fails.
// onInterceptRequest lets us answer them from local resources instead.
//
// Return null from the callback to let the Web load the resource normally.
// ArkTS strict mode does not accept a bare `null` here (the callback return
// type is WebResourceResponse), so we use `null!` — the `!` only erases the
// null at compile time; at runtime it is still null, i.e. "pass through".
@Entry
@Component
struct Ch30Intercept {
  private controller: webview.WebviewController = new webview.WebviewController();
  @State interceptEnabled: boolean = true;
  @State cacheModeValue: number = 0;
  @State logs: string[] = [];
  private cacheOptions: SelectOption[] = [
    { value: 'Default' },
    { value: 'None' },
    { value: 'Online' },
    { value: 'Only' }
  ];

  private addLog(msg: string): void {
    this.logs = [...this.logs, msg];
  }

  // Local JSON served as if it came from https://api.local/notes
  private notesJson(): string {
    return '{"items":[' +
      '{"title":"规则 1","desc":"按 URL 前缀匹配，命中才接管"},' +
      '{"title":"规则 2","desc":"返回 null 表示放行，交给 Web 自己加载"},' +
      '{"title":"规则 3","desc":"弱网时可用本地缓存兜底页面数据"}' +
      ']}';
  }

  // CacheMode values: Default = 0, None = 1, Online = 2, Only = 3
  private currentCacheMode(): CacheMode {
    if (this.cacheModeValue === 1) {
      return CacheMode.None;
    }
    if (this.cacheModeValue === 2) {
      return CacheMode.Online;
    }
    if (this.cacheModeValue === 3) {
      return CacheMode.Only;
    }
    return CacheMode.Default;
  }

  private buildImageResponse(): WebResourceResponse {
    let response: WebResourceResponse = new WebResourceResponse();
    response.setResponseData($r('app.media.startIcon'));
    response.setResponseMimeType('image/png');
    response.setResponseCode(200);
    response.setReasonMessage('OK');
    return response;
  }

  private buildJsonResponse(): WebResourceResponse {
    let response: WebResourceResponse = new WebResourceResponse();
    response.setResponseData(this.notesJson());
    response.setResponseMimeType('application/json');
    response.setResponseEncoding('utf-8');
    response.setResponseCode(200);
    response.setResponseHeader([{
      headerKey: 'Access-Control-Allow-Origin',
      headerValue: '*'
    }]);
    return response;
  }

  build() {
    Column() {
      Row() {
        Button('<')
          .fontSize(18)
          .width(40)
          .height(32)
          .backgroundColor(Color.Transparent)
          .fontColor('#317af7')
          .onClick(() => router.back())
        Text('请求拦截与离线兜底')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        Button('刷新')
          .fontSize(13)
          .height(28)
          .onClick(() => this.controller.refresh())
      }
      .width('100%')
      .padding({ left: 8, right: 12, top: 6, bottom: 6 })
      .backgroundColor('#F5F5F5')

      Row({ space: 10 }) {
        Toggle({ type: ToggleType.Switch, isOn: this.interceptEnabled })
          .onChange((isOn: boolean) => {
            this.interceptEnabled = isOn;
            this.controller.refresh();
          })
        Text(this.interceptEnabled ? '拦截已开启' : '拦截已关闭')
          .fontSize(13)

        Blank()

        Select(this.cacheOptions)
          .selected(this.cacheModeValue)
          .width(110)
          .onSelect((index: number) => {
            this.cacheModeValue = index;
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })

      Web({ src: $rawfile('intercept.html'), controller: this.controller })
        .width('100%')
        .layoutWeight(1)
        .javaScriptAccess(true)
        .cacheMode(this.currentCacheMode())
        .onInterceptRequest((event) => {
          let url: string = event.request.getRequestUrl();
          if (!this.interceptEnabled) {
            this.addLog('放行：' + url);
            return null!;
          }
          if (url.indexOf('demo.local/avatar.png') >= 0) {
            this.addLog('接管图片：' + url);
            return this.buildImageResponse();
          }
          if (url.indexOf('api.local/notes') >= 0) {
            this.addLog('接管数据：' + url);
            return this.buildJsonResponse();
          }
          this.addLog('放行：' + url);
          return null!;
        })

      Text('拦截日志')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .padding({ left: 12, top: 8 })

      List({ space: 2 }) {
        ForEach(this.logs, (item: string) => {
          ListItem() {
            Text(item)
              .fontSize(11)
              .fontColor('#666')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
              .padding({ left: 12, right: 12, top: 2, bottom: 2 })
          }
        }, (item: string, index: number) => index.toString())
      }
      .height(120)
      .width('100%')
      .divider({ strokeWidth: 0.5, color: '#EEE' })
    }
    .width('100%')
    .height('100%')
  }
}
