import { router} from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';

// Chapter 31 §三/§四/§五: raw AVPlayer with a custom video UI.
//
// The video surface is drawn by an XComponent (type = SURFACE). The pipeline:
//   createAVPlayer → set url → (initialized)
//     → bind surface (avPlayer.surfaceId = id)  ← MUST happen in the initialized state
//     → prepare() → (prepared) → play()
//
// CRITICAL: the surfaceId MUST be bound in the 'initialized' state, i.e. BEFORE prepare().
// The SDK only allows the FIRST surfaceId assignment in the initialized state; binding it
// for the first time after 'prepared' silently fails → black screen with audio only.
// So tryPrepare() gates on BOTH (a) AVPlayer 'initialized' and (b) XComponent onLoad, and
// only then calls prepare() with the surface already attached.
@Entry
@Component
struct Ch31AVPlayer {
  surfaceIdReady: boolean = false;
  srcInitialized: boolean = false;
  // Network source — requires ohos.permission.INTERNET (already declared).
  // For LOCAL: drop the file into resources/rawfile and use
  //   player.fdSrc = { fd: <from fileIo.open>, offset: 0, length: <fileSize> }
  private readonly videoUrl: string = 'https://media.w3.org/2010/05/sintel/trailer.mp4';

  private avPlayer: media.AVPlayer | undefined = undefined;
  private xcController: XComponentController = new XComponentController();

  // Surface gate flags.
  @State surfaceId: string = '';

  // Playback state (mirrors media.AVPlayerState).
  @State avState: media.AVPlayerState = 'idle';
  @State durationMs: number = 0;
  @State positionMs: number = 0;
  @State isPlaying: boolean = false;
  @State volume: number = 1;            // 0.0 ~ 1.0
  @State speedLabel: string = '1.0x';

  aboutToAppear(): void {
    media.createAVPlayer().then((player: media.AVPlayer) => {
      this.avPlayer = player;
      this.registerEvents(player);
      player.url = this.videoUrl;   // → state 'initialized'
    }).catch((error: BusinessError) => {
      console.error('createAVPlayer failed: ' + error.message);
    });
  }

  // Central state machine. EVERYTHING is driven by stateChange.
  private registerEvents(player: media.AVPlayer): void {
    player.on('stateChange', (state: media.AVPlayerState, reason: media.StateChangeReason) => {
      this.avState = state;
      if (reason === media.StateChangeReason.BACKGROUND) {
        // The system suspended us (e.g. app went to background). See deep point 9.2.
        console.info('AVPlayer suspended by system (background)');
      }
      if (state === 'initialized') {
        // Source is set. The surfaceId MUST be bound BEFORE prepare() — see tryPrepare().
        this.srcInitialized = true;
        this.tryPrepare();
      } else if (state === 'prepared') {
        // Surface was already bound by tryPrepare(); just start playback.
        player.play();
      } else if (state === 'playing') {
        this.isPlaying = true;
      } else if (state === 'paused') {
        this.isPlaying = false;
      } else if (state === 'completed') {
        this.isPlaying = false;
        // AVPlayer has no built-in loop; emulate it by seeking to 0 and replaying.
        player.seek(0, media.SeekMode.SEEK_NEXT_SYNC);
        player.play();
      }
    });

    // Progress comes ONLY from events — there is no getDuration()/getCurrentTime()
    // on AVPlayer. timeUpdate / durationUpdate / seekDone all report MILLISECONDS.
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
    // Audio focus: when another app takes the output, pause gracefully.
    player.on('audioInterrupt', () => {
      this.isPlaying = false;
    });
  }

  // Gate: bind surface then prepare(). The two prerequisites can arrive in EITHER order:
  //   (a) AVPlayer 'initialized'         (b) XComponent onLoad (surfaceId ready)
  // Both must be satisfied, and surfaceId must be set in the initialized state — i.e.
  // BEFORE prepare() — which the SDK requires (first assignment after 'prepared' → black
  // screen with audio only).
  private tryPrepare(): void {
    if (!this.srcInitialized || !this.avPlayer || !this.surfaceIdReady) {
      return;
    }
    if (this.surfaceId === '') {
      // onLoad fired but the id came back empty; try fetching once more.
      this.surfaceId = this.xcController.getXComponentSurfaceId();
      if (this.surfaceId === '') {
        return;
      }
    }
    this.avPlayer.surfaceId = this.surfaceId;   // bind BEFORE prepare()
    this.avPlayer.prepare();
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
    // seek() is void on AVPlayer (no Promise, no callback) — never await it.
    // The slider value is in ms; position UI updates via timeUpdate.
    this.avPlayer?.seek(value, media.SeekMode.SEEK_NEXT_SYNC);
  }

  private changeVolume(value: number): void {
    this.volume = value;
    // setVolume() is void on AVPlayer — just call it.
    this.avPlayer?.setVolume(value);
  }

  private changeSpeed(label: string, speed: media.PlaybackSpeed): void {
    this.speedLabel = label;
    // setSpeed() is void on AVPlayer.
    this.avPlayer?.setSpeed(speed);
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
        Text('② AVPlayer + XComponent')
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

      // The video canvas. XComponent holds the native surface; AVPlayer paints
      // into it via the `surfaceId` property. The surface MUST exist before play().
      XComponent({ id: 'avplayer-surface', type: XComponentType.SURFACE, controller: this.xcController })
        .onLoad(() => {
          // onLoad fires after the surface is created; grab its id and open the gate.
          this.surfaceId = this.xcController.getXComponentSurfaceId();
          this.surfaceIdReady = true;
          this.tryPrepare();
        })
        .width('100%')
        .height(240)
        .backgroundColor('#000')

      // Progress bar (ms). Slider max is durationMs; onChange seeks.
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

      // Volume (0~1).
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

      // Playback speed.
      Row({ space: 8 }) {
        Text('倍速')
          .fontSize(13)
          .width(40)
        Button('0.75x').fontSize(13).onClick(() => this.changeSpeed('0.75x', media.PlaybackSpeed.SPEED_FORWARD_0_75_X))
        Button('1.0x').fontSize(13).onClick(() => this.changeSpeed('1.0x', media.PlaybackSpeed.SPEED_FORWARD_1_00_X))
        Button('1.5x').fontSize(13).onClick(() => this.changeSpeed('1.5x', media.PlaybackSpeed.SPEED_FORWARD_1_50_X))
        Button('2.0x').fontSize(13).onClick(() => this.changeSpeed('2.0x', media.PlaybackSpeed.SPEED_FORWARD_2_00_X))
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8 })

      Text('关键：surfaceId 必须在 prepare() 之前（initialized 状态）绑定，否则黑屏有声音；用 gate 同时等「initialized」和「onLoad 拿到 surfaceId」，两者齐了才 prepare()。')
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
