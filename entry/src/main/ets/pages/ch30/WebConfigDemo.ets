import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

// Chapter 30 §五: the engineering switches you will actually ship with.
//   darkMode        — follow the system, or force light / dark
//   userAgent       — setCustomUserAgent() + getUserAgent()
//   textZoomRatio   — font scaling inside the page
//   initialScale    — initial page zoom
//   zoomAccess      — allow pinch-to-zoom
@Entry
@Component
struct Ch30WebConfig {
  private controller: webview.WebviewController = new webview.WebviewController();
  private darkModes: WebDarkMode[] = [WebDarkMode.Auto, WebDarkMode.On, WebDarkMode.Off];
  private darkModeOptions: SelectOption[] = [
    { value: '跟随系统' },
    { value: '强制深色' },
    { value: '强制浅色' }
  ];

  @State darkIndex: number = 0;
  @State customUa: string = '';
  @State currentUa: string = '';
  @State pageUa: string = '';
  @State textZoom: number = 100;
  @State initScale: number = 100;
  @State zoomEnabled: boolean = true;

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
        Text('深色模式 / UA / 缩放')
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

      Column({ space: 10 }) {
        Row({ space: 10 }) {
          Text('深色模式')
            .fontSize(13)
            .width(70)
          Select(this.darkModeOptions)
            .selected(this.darkIndex)
            .layoutWeight(1)
            .onSelect((index: number) => {
              this.darkIndex = index;
              this.controller.refresh();
            })
        }
        .width('100%')

        Row({ space: 10 }) {
          Text('自定义 UA')
            .fontSize(13)
            .width(70)
          TextInput({ placeholder: '留空则使用系统 UA' })
            .fontSize(13)
            .layoutWeight(1)
            .height(34)
            .onChange((value: string) => {
              this.customUa = value;
            })
          Button('应用')
            .fontSize(13)
            .height(30)
            .onClick(() => {
              // An empty string restores the default user agent.
              this.controller.setCustomUserAgent(this.customUa);
              this.currentUa = this.controller.getUserAgent();
              this.controller.refresh();
            })
        }
        .width('100%')

        Row({ space: 10 }) {
          Text('文字缩放')
            .fontSize(13)
            .width(70)
          Slider({ value: this.textZoom, min: 50, max: 200, step: 5 })
            .layoutWeight(1)
            .onChange((value: number) => {
              this.textZoom = value;
            })
          Text(this.textZoom + '%')
            .fontSize(12)
            .width(44)
        }
        .width('100%')

        Row({ space: 10 }) {
          Text('初始缩放')
            .fontSize(13)
            .width(70)
          Slider({ value: this.initScale, min: 50, max: 300, step: 10 })
            .layoutWeight(1)
            .onChange((value: number) => {
              this.initScale = value;
            })
          Text(this.initScale + '%')
            .fontSize(12)
            .width(44)
        }
        .width('100%')

        Row({ space: 10 }) {
          Text('双指缩放')
            .fontSize(13)
            .width(70)
          Toggle({ type: ToggleType.Switch, isOn: this.zoomEnabled })
            .onChange((isOn: boolean) => {
              this.zoomEnabled = isOn;
            })
          Blank()
          Button('读 H5 里的 UA')
            .fontSize(12)
            .height(28)
            .onClick(() => {
              this.controller.runJavaScript('getPageUserAgent()')
                .then((result: string) => {
                  this.pageUa = result;
                })
                .catch(() => {
                  this.pageUa = '读取失败';
                });
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(12)

      // Load the local H5 via $rawfile — paints reliably on device (the earlier
      // about:blank + loadData combo navigated but stayed blank on some versions).
      Web({ src: $rawfile('basic.html'), controller: this.controller })
        .width('100%')
        .layoutWeight(1)
        .javaScriptAccess(true)
        .darkMode(this.darkModes[this.darkIndex])
        .forceDarkAccess(true)
        .textZoomRatio(this.textZoom)
        .initialScale(this.initScale)
        .zoomAccess(this.zoomEnabled)

      Column({ space: 2 }) {
        Text('ArkTS 读到的 UA：' + (this.currentUa === '' ? '未修改' : this.currentUa))
          .fontSize(11)
          .fontColor('#888')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text('H5 内部 UA：' + (this.pageUa === '' ? '点上方按钮读取' : this.pageUa))
          .fontSize(11)
          .fontColor('#888')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 6, bottom: 10 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
  }
}
