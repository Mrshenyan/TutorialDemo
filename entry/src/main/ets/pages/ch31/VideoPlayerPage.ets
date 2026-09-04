import { router } from '@kit.ArkUI';

// Chapter 31 §二: declarative Video component — the fast path.
//
// The Video component wraps AVPlayer + XComponent internally, so you get a
// working player with almost no code. Use it when the built-in controls are
// enough; switch to raw AVPlayer (demo ②/③) only when you need a custom UI.
@Entry
@Component
struct Ch31VideoPlayer {
  // VideoController drives the player from ArkTS (start / pause / seek / fullscreen).
  private controller: VideoController = new VideoController();

  // Network source — requires ohos.permission.INTERNET (already declared in
  // module.json5). For a LOCAL file, drop it into resources/rawfile and use
  // src: $rawfile('demo.mp4') instead.
  private readonly videoUrl: string = 'https://media.w3.org/2010/05/sintel/trailer.mp4';

  // NOTE: the Video component reports time in SECONDS, while AVPlayer's
  // timeUpdate event reports MILLISECONDS. Don't mix the two units when porting.
  @State durationSec: number = 0;
  @State currentSec: number = 0;
  @State isPlaying: boolean = false;

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
        Text('① 声明式 Video 组件')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: 12, top: 6, bottom: 6 })
      .backgroundColor('#F5F5F5')

      Video({
        src: this.videoUrl,
        controller: this.controller,
        previewUri: $r('app.media.startIcon')
      })
        .width('100%')
        .height(240)
        .controls(true)        // show the system control bar
        .autoPlay(false)
        .loop(false)
        .onPrepared((event) => {
          // event.duration is in SECONDS (float).
          this.durationSec = event.duration;
        })
        .onUpdate((event) => {
          // event.time is in SECONDS.
          this.currentSec = event.time;
        })
        .onStart(() => {
          this.isPlaying = true;
        })
        .onPause(() => {
          this.isPlaying = false;
        })
        .onFinish(() => {
          this.isPlaying = false;
          this.currentSec = 0;
        })
        .onError(() => {
          // Replace with your own error UI as needed.
          console.error('Video playback error');
        })

      // Custom controls — demonstrates VideoController. The Video already has its
      // native controls above; these buttons show how ArkTS can drive it too.
      Row({ space: 12 }) {
        Button(this.isPlaying ? '暂停' : '播放')
          .fontSize(14)
          .onClick(() => {
            if (this.isPlaying) {
              this.controller.pause();
            } else {
              this.controller.start();
            }
          })
        Button('回到开头')
          .fontSize(14)
          .onClick(() => {
            this.controller.setCurrentTime(0);
          })
        Button('全屏')
          .fontSize(14)
          .onClick(() => {
            this.controller.requestFullscreen(true);
          })
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F5F5F5')

      Text('进度：' + this.currentSec.toFixed(1) + 's / ' + this.durationSec.toFixed(1) + 's')
        .fontSize(13)
        .fontColor('#666')
        .padding({ left: 12 })

      Text('提示：Video 组件自带控制条（controls(true)）。它底层就是 AVPlayer + XComponent 的封装；想要完全自定义的 UI 见 Demo ②。')
        .fontSize(12)
        .fontColor('#888')
        .padding(12)
    }
    .width('100%')
    .height('100%')
  }
}
