import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

// Chapter 30 §一: load a LOCAL H5 page and wire up the loading lifecycle.
//
// Why $rawfile() (NOT inline loadData):
//   The page lives in entry/src/main/resources/rawfile/basic.html and is loaded
//   with `src: $rawfile('basic.html')`. This is the genuine "load a local H5
//   file" story and it paints reliably on device. An earlier build used
//   `src: 'about:blank'` + `controller.loadData()` inside onControllerAttached —
//   that navigates and fires the FULL lifecycle (onPageBegin/End/Visible all
//   fire) yet the surface stays BLANK on some devices/API versions, so it was
//   dropped. $rawfile matches the structure demo ②/③ already prove renders.
//
// Two hard rules:
//   1) The controller is bound only after onControllerAttached fires. Calling
//      WebviewController methods before that throws error 17100001.
//   2) Back key: ask the Web first (accessBackward), only pop when it's empty.
//
// Layout: the Web lives inside a weighted Column wrapper (.layoutWeight(1)), and
// the Web itself is .height('100%') of that wrapper. This isolates the Web's
// height from the conditional Progress (above) and the log List (below): when
// progress hits 100 the Progress node is removed, and on some API levels a
// structural re-layout next to a layoutWeight child drops the Web's height to 0
// (that collapse is exactly why this wrapper exists). The wrapper keeps a definite
// height so the surface never collapses to 0 after the page loads.
// (A bare Stack wrapper holding the Web's layoutWeight is still forbidden — Stack
// has no main axis, the weight is ignored, Web collapses to 0.)
@Entry
@Component
struct Ch30BasicWeb {
  private controller: webview.WebviewController = new webview.WebviewController();
  @State progress: number = 0;
  @State pageTitle: string = '加载中…';
  @State hasError: boolean = false;
  @State errorMessage: string = '';
  @State canGoBack: boolean = false;
  @State logs: string[] = [];

  private addLog(msg: string): void {
    this.logs = [...this.logs, msg];
  }

  // Intercept the system back gesture: let the Web go back first.
  onBackPress(): boolean {
    if (this.controller.accessBackward()) {
      this.controller.backward();
      return true; // consumed here, page stays
    }
    return false; // nothing left in history, let the page pop
  }

  build() {
    Column() {
      // Native top bar — this is exactly why hybrid shells exist.
      Row() {
        Button('<')
          .fontSize(18)
          .width(40)
          .height(32)
          .backgroundColor(Color.Transparent)
          .fontColor('#317af7')
          .onClick(() => router.back())

        Text(this.pageTitle)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        Button('后退')
          .fontSize(13)
          .height(28)
          .enabled(this.canGoBack)
          .onClick(() => {
            if (this.controller.accessBackward()) {
              this.controller.backward();
            }
          })

        Button('刷新')
          .fontSize(13)
          .height(28)
          .margin({ left: 6 })
          .onClick(() => {
            this.hasError = false;
            this.controller.refresh();
          })

        Button('读 UA')
          .fontSize(13)
          .height(28)
          .margin({ left: 6 })
          .onClick(() => {
            // Native → H5: ask the page for its UserAgent. The page fills its own
            // <b id="ua"> row, and we log the value returned by runJavaScript.
            this.controller.runJavaScript('getPageUserAgent()')
              .then((ua: string) => {
                this.addLog('runJavaScript → UA：' + ua);
              })
              .catch((err: Error) => {
                this.addLog('runJavaScript 失败：' + err.message);
              });
          })
      }
      .width('100%')
      .padding({ left: 8, right: 12, top: 6, bottom: 6 })
      .backgroundColor('#F5F5F5')

      if (this.progress < 100) {
        Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(2)
          .color('#317af7')
      }

      // Weighted wrapper: isolates the Web's height from the conditional Progress
      // above and the log List below. Web is .height('100%') of this definite
      // container, so removing the Progress node on load-complete never collapses
      // the surface (some API levels drop a bare layoutWeight child on re-layout).
      Column() {
        // Error fallback is a conditional SIBLING of the Web (overlay cannot hold
        // UI components here). When hasError is true the Web is torn down and the
        // card shows; tapping 重新加载 flips hasError back and the Web reloads.
        if (this.hasError) {
          Column({ space: 10 }) {
            Text('页面加载失败')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Text(this.errorMessage)
              .fontSize(12)
              .fontColor('#999')
              .padding({ left: 24, right: 24 })
              .textAlign(TextAlign.Center)
            Button('重新加载')
              .onClick(() => {
                this.hasError = false;
              })
          }
          .width('100%')
          .height(100)
          .backgroundColor('#ffdd0101')
          .justifyContent(FlexAlign.Center)
        } else {
          // Fills the weighted wrapper; height('100%') resolves against a definite
          // parent, so it never collapses to 0 after the page loads.
          Web({ src: $rawfile('basic.html'), controller: this.controller })
            .width('100%')
            .height('100%')
            .javaScriptAccess(true)
            .domStorageAccess(true)
            .onPageBegin(() => {
              this.hasError = false;
              this.progress = 0;
              this.addLog('onPageBegin：开始加载');
            })
            .onProgressChange((event) => {
              this.progress = event.newProgress;
            })
            .onPageEnd(() => {
              this.canGoBack = this.controller.accessBackward();
              this.addLog('onPageEnd：加载完成');
            })
            .onPageVisible((event: OnPageVisibleEvent) => {
              this.addLog('onPageVisible：' + event.url);
            })
            .onTitleReceive((event) => {
              this.pageTitle = event.title;
            })
            .onErrorReceive((event) => {
              this.hasError = true;
              this.errorMessage = '资源加载失败 code=' + event.error.getErrorCode() +
                ' url=' + event.request.getRequestUrl();
              this.addLog('onErrorReceive：' + event.error.getErrorInfo());
            })
            .onHttpErrorReceive((event) => {
              this.hasError = true;
              this.errorMessage = 'HTTP 错误 ' + event.response.getResponseCode() +
                ' ' + event.response.getReasonMessage();
            })
            // Diagnostics: surface hidden failures when the page looks blank.
            .onConsole((event: OnConsoleEvent): boolean => {
              this.addLog('onConsole：' + event.message.getMessage());
              return false; // let the default console behavior run
            })
            .onAlert((event: OnAlertEvent): boolean => {
              this.addLog('onAlert：' + event.message);
              event.result.handleConfirm();
              return true; // we handled the dialog
            })
            .onRenderExited((event: OnRenderExitedEvent) => {
              this.addLog('onRenderExited：reason=' + event.renderExitReason);
            })
        }
      }
      .layoutWeight(1)
      .width('100%')

      Text('生命周期日志')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .padding({ left: 12, top: 8 })

      List({ space: 2 }) {
        ForEach(this.logs, (item: string) => {
          ListItem() {
            Text(item)
              .fontSize(12)
              .fontColor('#666')
              .width('100%')
              .padding({ left: 12, right: 12, top: 3, bottom: 3 })
          }
        }, (item: string, index: number) => index.toString())
      }
      .height(180)
      .width('100%')
      .divider({ strokeWidth: 0.5, color: '#EEE' })
    }
    .width('100%')
    .height('100%')
  }
}
