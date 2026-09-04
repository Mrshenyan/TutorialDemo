import { router } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';

// Chapter 31 §六: pure AUDIO playback with AVPlayer.
//
// The state machine is IDENTICAL to the video demo — the ONLY difference is
// there is no XComponent and no setDisplaySurface() call. Audio just needs the
// url → prepare() → play() sequence. This proves "AVPlayer is media-agnostic;
// the surface is what makes it video".
@Entry
@Component
struct Ch31AudioPlayer {
  // Network audio (INTERNET already declared). Swap for $rawfile('xx.mp3') locally.
  private readonly audioUrl: string = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  private avPlayer: media.AVPlayer | undefined = undefined;

  @State avState: media.AVPlayerState = 'idle';
  @State durationMs: number = 0;
  @State positionMs: number = 0;
  @State isPlaying: boolean = false;
  @State volume: number = 1;

  aboutToAppear(): void {
    media.createAVPlayer().then((player: media.AVPlayer) => {
      this.avPlayer = player;
      this.registerEvents(player);
      player.url = this.audioUrl;
    }).catch((error: BusinessError) => {
      console.error('createAVPlayer failed: ' + error.message);
    });
  }

  private registerEvents(player: media.AVPlayer): void {
    player.on('stateChange', (state: media.AVPlayerState, reason: media.StateChangeReason) => {
      this.avState = state;
      if (reason === media.StateChangeReason.BACKGROUND) {
        console.info('AVPlayer suspended by system (background)');
      }
      if (state === 'initialized') {
        player.prepare();
      } else if (state === 'prepared') {
        player.play();
      } else if (state === 'playing') {
        this.isPlaying = true;
      } else if (state === 'paused') {
        this.isPlaying = false;
      } else if (state === 'completed') {
        this.isPlaying = false;
      }
    });
    player.on('durationUpdate', (duration: number) => {
      this.durationMs = duration;
    });
    player.on('timeUpdate', (time: number) => {
      this.positionMs = time;
    });
    player.on('seekDone', (time: number) => {
      this.positionMs = time;
    });
    player.on('error', (error: BusinessError) => {
      console.error('AVPlayer error: ' + error.code + ' ' + error.message);
    });
    // Audio focus handled via audioInterrupt.
    player.on('audioInterrupt', () => {
      this.isPlaying = false;
    });
  }

  private togglePlay(): void {
    if (!this.avPlayer) {
      return;
    }
    if (this.isPlaying) {
      this.avPlayer.pause();
    } else {
      this.avPlayer.play();
    }
  }

  private onSeek(value: number): void {
    this.avPlayer?.seek(value, media.SeekMode.SEEK_NEXT_SYNC);
  }

  private changeVolume(value: number): void {
    this.volume = value;
    this.avPlayer?.setVolume(value);
  }

  aboutToDisappear(): void {
    // Always release the player when leaving the page to free the decoder.
    if (this.avPlayer) {
      this.avPlayer.release();
      this.avPlayer = undefined;
    }
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
        Text('③ AVPlayer 纯音频')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        Text(this.avState)
          .fontSize(12)
          .fontColor('#999')
      }
      .width('100%')
      .padding({ left: 8, right: 12, top: 6, bottom: 6 })
      .backgroundColor('#F5F5F5')

      // No XComponent here — audio has no visual surface.
      Column({ space: 8 }) {
        Text('🎵 纯音频播放（无画面）')
          .fontSize(16)
        Text('状态：' + this.avState)
          .fontSize(13)
          .fontColor('#666')
      }
      .width('100%')
      .height(160)
      .backgroundColor('#1b1b1b')
      .justifyContent(FlexAlign.Center)

      Row({ space: 8 }) {
        Text(this.formatMs(this.positionMs))
          .fontSize(12)
          .fontColor('#666')
          .width(48)
        Slider({
          value: this.positionMs,
          min: 0,
          max: this.durationMs > 0 ? this.durationMs : 1,
          step: 500,
          style: SliderStyle.OutSet
        })
          .layoutWeight(1)
          .onChange((value: number) => {
            this.onSeek(value);
          })
        Text(this.formatMs(this.durationMs))
          .fontSize(12)
          .fontColor('#666')
          .width(48)
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8 })

      Row({ space: 12 }) {
        Button(this.isPlaying ? '暂停' : '播放')
          .fontSize(14)
          .onClick(() => this.togglePlay())
      }
      .width('100%')
      .padding({ left: 12, right: 12 })

      Row({ space: 8 }) {
        Text('音量')
          .fontSize(13)
          .width(40)
        Slider({
          value: this.volume,
          min: 0,
          max: 1,
          step: 0.05,
          style: SliderStyle.OutSet
        })
          .layoutWeight(1)
          .onChange((value: number) => {
            this.changeVolume(value);
          })
        Text(this.volume.toFixed(2))
          .fontSize(12)
          .fontColor('#666')
          .width(40)
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8 })

      Text('与视频 Demo 的唯一区别：没有 XComponent、不调 setDisplaySurface。状态机（initialized→prepared→playing）一字不差。')
        .fontSize(12)
        .fontColor('#888')
        .padding(12)
    }
    .width('100%')
    .height('100%')
  }

  private formatMs(ms: number): string {
    const totalSec: number = Math.floor(ms / 1000);
    const m: number = Math.floor(totalSec / 60);
    const s: number = totalSec % 60;
    return (m < 10 ? '0' + m : '' + m) + ':' + (s < 10 ? '0' + s : '' + s);
  }
}
