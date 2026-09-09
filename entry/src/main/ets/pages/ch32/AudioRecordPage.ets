import { router } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';

// Chapter 32 §一/§二: pure AUDIO recording with AVRecorder + playback with AVPlayer.
//
// The recording pipeline mirrors the ch31 playback state machine, just inverted:
//   createAVRecorder -> prepare(config) -> start -> pause/resume -> stop -> release
// Key differences from ch31:
//   1. AVRecorder needs a writable output file fd (fd://<fd>), not a url.
//   2. The MICROPHONE permission is user_grant: must be declared in module.json5
//      AND requested at runtime via abilityAccessCtrl.
//   3. prepare() is annotated @permission ohos.permission.MICROPHONE.
@Entry
@Component
struct Ch32AudioRecord {
  private avRecorder: media.AVRecorder | undefined = undefined;
  private avPlayer: media.AVPlayer | undefined = undefined;
  private fileFd: number = -1;
  private filePath: string = '';

  @State recState: media.AVRecorderState = 'idle';
  @State isRecording: boolean = false;
  @State hasRecording: boolean = false;
  @State isPlaying: boolean = false;
  @State durationMs: number = 0;
  @State positionMs: number = 0;

  // Step 1: request the microphone permission (user_grant) before any AVRecorder call.
  private async ensureMicPermission(): Promise<boolean> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();
    const result = await atManager.requestPermissionsFromUser(
      context,
      ['ohos.permission.MICROPHONE'] as Permissions[]
    );
    return result.authResults.every((r: number) => r === 0);
  }

  // Step 2: create the output file in the app sandbox and keep its fd.
  private createOutputFile(): void {
    this.filePath = getContext(this).filesDir + '/record_' + Date.now() + '.m4a';
    const file = fileIo.openSync(this.filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
    this.fileFd = file.fd;
  }

  // Step 3: build AVRecorder, configure for audio-only, start.
  async startRecord(): Promise<void> {
    const granted: boolean = await this.ensureMicPermission();
    if (!granted) {
      console.error('Microphone permission denied');
      return;
    }
    this.createOutputFile();
    try {
      this.avRecorder = await media.createAVRecorder();
      this.registerRecorderEvents(this.avRecorder);
      const profile: media.AVRecorderProfile = {
        audioBitrate: 48000,
        audioChannels: 2,
        audioCodec: media.CodecMimeType.AUDIO_AAC,
        audioSampleRate: 48000,
        fileFormat: media.ContainerFormatType.CFT_MPEG_4
      };
      const config: media.AVRecorderConfig = {
        audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
        profile: profile,
        url: 'fd://' + this.fileFd,
        rotation: 0
      };
      await this.avRecorder.prepare(config);
      await this.avRecorder.start();
    } catch (error) {
      const err = error as BusinessError;
      console.error('startRecord failed: ' + err.code + ' ' + err.message);
    }
  }

  private registerRecorderEvents(recorder: media.AVRecorder): void {
    recorder.on('stateChange', (state: media.AVRecorderState) => {
      this.recState = state;
      this.isRecording = (state === 'started');
    });
    recorder.on('error', (error: BusinessError) => {
      console.error('AVRecorder error: ' + error.code + ' ' + error.message);
    });
  }

  private pauseRecord(): void {
    this.avRecorder?.pause();
  }

  private resumeRecord(): void {
    this.avRecorder?.resume();
  }

  private async stopRecord(): Promise<void> {
    if (!this.avRecorder) {
      return;
    }
    await this.avRecorder.stop();
    this.hasRecording = true;
    // Close the fd so the m4a file is flushed to disk.
    if (this.fileFd >= 0) {
      fileIo.closeSync(this.fileFd);
      this.fileFd = -1;
    }
  }

  // Playback reuses the exact AVPlayer state machine from ch31.
  private async playRecording(): Promise<void> {
    if (!this.hasRecording) {
      return;
    }
    this.avPlayer = await media.createAVPlayer();
    this.registerPlayerEvents(this.avPlayer);
    this.avPlayer.url = this.filePath;
  }

  private registerPlayerEvents(player: media.AVPlayer): void {
    player.on('stateChange', (state: media.AVPlayerState) => {
      if (state === 'initialized') {
        player.prepare();
      } else if (state === 'prepared') {
        player.play();
      } else if (state === 'playing') {
        this.isPlaying = true;
      } else if (state === 'paused' || state === 'completed') {
        this.isPlaying = false;
      }
    });
    player.on('timeUpdate', (time: number) => { this.positionMs = time; });
    player.on('durationUpdate', (duration: number) => { this.durationMs = duration; });
    player.on('error', (error: BusinessError) => {
      console.error('AVPlayer error: ' + error.code + ' ' + error.message);
    });
  }

  private togglePlay(): void {
    if (this.isPlaying) {
      this.avPlayer?.pause();
    } else {
      this.avPlayer?.play();
    }
  }

  aboutToDisappear(): void {
    if (this.avRecorder) {
      this.avRecorder.release();
      this.avRecorder = undefined;
    }
    if (this.avPlayer) {
      this.avPlayer.release();
      this.avPlayer = undefined;
    }
    if (this.fileFd >= 0) {
      fileIo.closeSync(this.fileFd);
      this.fileFd = -1;
    }
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Button('<')
          .fontSize(18)
          .width(40)
          .height(32)
          .backgroundColor(Color.Transparent)
          .fontColor('#317af7')
          .onClick(() => router.back())
        Text('① 麦克风录音')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        Text(this.recState)
          .fontSize(12)
          .fontColor('#999')
      }
      .width('100%')
      .padding({ left: 8, right: 12, top: 6, bottom: 6 })
      .backgroundColor('#F5F5F5')

      Column({ space: 8 }) {
        Text('🎙️ 对着麦克风说话，录成 m4a')
          .fontSize(16)
        Text('状态：' + this.recState + (this.hasRecording ? ' · 已存 ' + this.filePath : ''))
          .fontSize(12)
          .fontColor('#666')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#1b1b1b')
      .justifyContent(FlexAlign.Center)

      Row({ space: 8 }) {
        Button('开始录音')
          .enabled(!this.isRecording)
          .onClick(() => this.startRecord())
        Button('暂停')
          .enabled(this.isRecording)
          .onClick(() => this.pauseRecord())
        Button('继续')
          .onClick(() => this.resumeRecord())
        Button('停止')
          .onClick(() => this.stopRecord())
      }
      .width('100%')
      .padding({ left: 12, right: 12 })

      Divider().margin({ top: 8, bottom: 8 })

      Row({ space: 8 }) {
        Button(this.isPlaying ? '暂停播放' : '播放录音')
          .backgroundColor('#2E7D32')
          .enabled(this.hasRecording)
          .onClick(() => this.togglePlay())
        Text(this.formatMs(this.positionMs) + ' / ' + this.formatMs(this.durationMs))
          .fontSize(12)
          .fontColor('#666')
      }
      .width('100%')
      .padding({ left: 12, right: 12 })

      Text('对比 ch31：播放端是 url → prepare → play；录制端是 fd → prepare → start。状态机心智完全一致。')
        .fontSize(12)
        .fontColor('#888')
        .padding(12)
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }

  private formatMs(ms: number): string {
    const totalSec: number = Math.floor(ms / 1000);
    const m: number = Math.floor(totalSec / 60);
    const s: number = totalSec % 60;
    return (m < 10 ? '0' + m : '' + m) + ':' + (s < 10 ? '0' + s : '' + s);
  }
}
