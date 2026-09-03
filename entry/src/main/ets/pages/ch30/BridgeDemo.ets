import { router, promptAction } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { deviceInfo, BusinessError } from '@kit.BasicServicesKit';

// The ArkTS object injected into the H5 page.
//
// Two hard rules for an injected object:
//   1) Only the methods listed in `methodList` are callable from JavaScript.
//      Anything else silently does nothing — no error, no warning.
//   2) The return value can only be a primitive type (string / number / boolean).
//      Objects must be serialized with JSON.stringify first.
class NativeBridge {
  onToast: (msg: string) => void = () => {};
  onReport: (count: number) => void = () => {};
  onClose: () => void = () => {};

  showToast(message: string): void {
    this.onToast(message);
  }

  getDeviceInfo(): string {
    let info: Record<string, string> = {
      'deviceType': deviceInfo.deviceType,
      'osVersion': deviceInfo.osFullName
    };
    return JSON.stringify(info);
  }

  reportCount(count: number): void {
    this.onReport(count);
  }

  closePage(): void {
    this.onClose();
  }
}

// Chapter 30 §二/§三: the two directions of a hybrid bridge.
//   H5  -> native : javaScriptProxy injects `NativeBridge`, H5 calls window.NativeBridge.xxx()
//   native -> H5  : controller.runJavaScript() runs a script inside the page
@Entry
@Component
struct Ch30Bridge {
  private controller: webview.WebviewController = new webview.WebviewController();
  private bridge: NativeBridge = new NativeBridge();
  @State reportedCount: number = 0;
  @State lastResult: string = '尚无调用';
  @State noteIndex: number = 0;
  @State isDarkTheme: boolean = false;

  aboutToAppear(): void {
    // Wire the bridge callbacks to this page's state.
    this.bridge.onToast = (msg: string) => {
      promptAction.showToast({ message: msg });
    };
    this.bridge.onReport = (count: number) => {
      this.reportedCount = count;
    };
    this.bridge.onClose = () => {
      router.back();
    };
  }

  aboutToDisappear(): void {
    // Always unregister when the page goes away, otherwise the Web component
    // keeps holding the injected object and it leaks.
    // NOTE: the SDK doc comment calls this deleteJavaScriptProxy — the real
    // method name is deleteJavaScriptRegister. Copying the comment will not compile.
    try {
      this.controller.deleteJavaScriptRegister('NativeBridge');
    } catch (error) {
      console.error('deleteJavaScriptRegister failed: ' + (error as BusinessError).message);
    }
  }

  private runJs(script: string, label: string): void {
    this.controller.runJavaScript(script)
      .then((result: string) => {
        this.lastResult = label + ' 返回：' + result;
      })
      .catch((error: BusinessError) => {
        this.lastResult = label + ' 失败：' + error.message;
      });
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
        Text('原生 ⇄ H5 双向通信')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: 12, top: 6, bottom: 6 })
      .backgroundColor('#F5F5F5')

      Column({ space: 4 }) {
        Text('H5 上报计数：' + this.reportedCount)
          .fontSize(13)
        Text('runJavaScript 结果：' + this.lastResult)
          .fontSize(12)
          .fontColor('#888')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .alignItems(HorizontalAlign.Start)

      Web({ src: $rawfile('hybrid.html'), controller: this.controller })
        .width('100%')
        .layoutWeight(1)
        .javaScriptAccess(true)
        .domStorageAccess(true)
        // Declarative injection: the page can now call window.NativeBridge.xxx()
        .javaScriptProxy({
          object: this.bridge,
          name: 'NativeBridge',
          methodList: ['showToast', 'getDeviceInfo', 'reportCount', 'closePage'],
          controller: this.controller
        })

      Column({ space: 8 }) {
        Row({ space: 8 }) {
          Button('插入一条')
            .fontSize(13)
            .layoutWeight(1)
            .onClick(() => {
              this.noteIndex += 1;
              this.runJs("appendNote('来自原生 #" + this.noteIndex + "')", 'appendNote');
            })
          Button('读条目数')
            .fontSize(13)
            .layoutWeight(1)
            .onClick(() => this.runJs('getNoteCount()', 'getNoteCount'))
          Button('清空')
            .fontSize(13)
            .layoutWeight(1)
            .onClick(() => this.runJs('clearNotes()', 'clearNotes'))
        }
        .width('100%')

        Row({ space: 8 }) {
          Button(this.isDarkTheme ? '换回浅色' : '换深色主题')
            .fontSize(13)
            .layoutWeight(1)
            .onClick(() => {
              this.isDarkTheme = !this.isDarkTheme;
              this.runJs("setTheme('" + (this.isDarkTheme ? 'dark' : 'default') + "')", 'setTheme');
            })
          Button('读 H5 里的 UA')
            .fontSize(13)
            .layoutWeight(1)
            .onClick(() => this.runJs('getPageUserAgent()', 'getPageUserAgent'))
          Button('错误示范')
            .fontSize(13)
            .layoutWeight(1)
            .backgroundColor('#B3261E')
            .onClick(() => this.runJs('({ a: 1 })', '直接返回对象'))
        }
        .width('100%')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}
