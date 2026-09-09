import { router } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';

type Tier = 'high' | 'std' | 'low';

// Chapter 32 §进阶一: parameter tuning. The same AVRecorder API from the basics section, but we now
// drive it with different AVRecorderProfile presets to trade quality for file size.
// Every value below sits inside the SDK-allowed ranges (see @ohos.multimedia.media.d.ts):
//   AAC bitrate 32000-500000, sampleRate ∈ {8000..96000}, channels 1-8,
//   rotation ∈ {0, 90, 180, 270}. aacProfile is an API 22 addition (defaults to AAC_LC).
@Entry
@Component
struct Ch32AudioTuner {
  private avRecorder: media.AVRecorder | undefined = undefined;
  private fileFd: number = -1;
  private filePath: string = '';

  @State tier: Tier = 'std';
  @State rotation: number = 0;
  @State aacProfile: media.AacProfile = media.AacProfile.AAC_LC;
  @State isRecording: boolean = false;
  @State recState: string = 'idle';
  @State hasRecording: boolean = false;

  private tierLabels: Record<Tier, string> = {
    "high": '高清 · 192k/48k/双声道',
    "std": '标准 · 96k/44.1k/双声道',
    "low": '省流 · 32k/16k/单声道'
  };

  // Build a fresh profile object from the current selections (no shared-reference side effects).
  private buildProfile(): media.AVRecorderProfile {
    let p: media.AVRecorderProfile;
    if (this.tier === 'high') {
      p = {
        audioBitrate: 192000,
        audioChannels: 2,
        audioCodec: media.CodecMimeType.AUDIO_AAC,
        audioSampleRate: 48000,
        fileFormat: media.ContainerFormatType.CFT_MPEG_4
      };
    } else if (this.tier === 'low') {
      p = {
        audioBitrate: 32000,
        audioChannels: 1,
        audioCodec: media.CodecMimeType.AUDIO_AAC,
        audioSampleRate: 16000,
        fileFormat: media.ContainerFormatType.CFT_MPEG_4
      };
    } else {
      p = {
        audioBitrate: 96000,
        audioChannels: 2,
        audioCodec: media.CodecMimeType.AUDIO_AAC,
        audioSampleRate: 44100,
        fileFormat: media.ContainerFormatType.CFT_MPEG_4
      };
    }
    p.aacProfile = this.aacProfile; // API 22: optional, defaults to AAC_LC
    return p;
  }

  private async ensureMicPermission(): Promise<boolean> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();
    const result = await atManager.requestPermissionsFromUser(
      context,
      ['ohos.permission.MICROPHONE'] as Permissions[]
    );
    return result.authResults.every((r: number) => r === 0);
  }

  private createOutputFile(): void {
    this.filePath = getContext(this).filesDir + '/tuner_' + Date.now() + '.m4a';
    const file = fileIo.openSync(this.filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
    this.fileFd = file.fd;
  }

  async startRecord(): Promise<void> {
    const granted: boolean = await this.ensureMicPermission();
    if (!granted) {
      console.error('Microphone permission denied');
      return;
    }
    this.createOutputFile();
    try {
      this.avRecorder = await media.createAVRecorder();
      this.avRecorder.on('stateChange', (state: media.AVRecorderState) => {
        this.recState = state;
        this.isRecording = (state === 'started');
      });
      this.avRecorder.on('error', (error: BusinessError) => {
        console.error('AVRecorder error: ' + error.code + ' ' + error.message);
      });
      const config: media.AVRecorderConfig = {
        audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
        profile: this.buildProfile(),
        url: 'fd://' + this.fileFd,
        rotation: this.rotation
      };
      await this.avRecorder.prepare(config);
      await this.avRecorder.start();
    } catch (error) {
      const err = error as BusinessError;
      console.error('startRecord failed: ' + err.code + ' ' + err.message);
    }
  }

  private async stopRecord(): Promise<void> {
    if (!this.avRecorder) {
      return;
    }
    await this.avRecorder.stop();
    this.hasRecording = true;
    if (this.fileFd >= 0) {
      fileIo.closeSync(this.fileFd);
      this.fileFd = -1;
    }
  }

  aboutToDisappear(): void {
    if (this.avRecorder) {
      this.avRecorder.release();
      this.avRecorder = undefined;
    }
    if (this.fileFd >= 0) {
      fileIo.closeSync(this.fileFd);
      this.fileFd = -1;
    }
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Button('<')
          .fontSize(18)
          .width(40)
          .height(32)
          .backgroundColor(Color.Transparent)
          .fontColor('#317af7')
          .onClick(() => router.back())
        Text('① 参数精调体系')
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

      Text('选择录制档位（质量 ↔ 体积）').fontSize(14).fontWeight(FontWeight.Medium)
      Row({ space: 8 }) {
        ForEach(['high', 'std', 'low'] as Tier[], (t: Tier) => {
          Button(this.tierLabels[t])
            .fontSize(12)
            .backgroundColor(this.tier === t ? '#1565C0' : '#ccc')
            .onClick(() => { this.tier = t; })
        })
      }
      .width('100%')
      .padding({ left: 12, right: 12 })

      Text('横竖屏（rotation）').fontSize(14).fontWeight(FontWeight.Medium)
      Row({ space: 8 }) {
        ForEach([0, 90, 180, 270], (r: number) => {
          Button(r + '°')
            .fontSize(13)
            .backgroundColor(this.rotation === r ? '#1565C0' : '#ccc')
            .onClick(() => { this.rotation = r; })
        })
      }
      .width('100%')
      .padding({ left: 12, right: 12 })

      Text('AAC 规格（API 22 新增 aacProfile）').fontSize(14).fontWeight(FontWeight.Medium)
      Row({ space: 8 }) {
        Button('AAC_LC（默认）')
          .fontSize(12)
          .backgroundColor(this.aacProfile === media.AacProfile.AAC_LC ? '#1565C0' : '#ccc')
          .onClick(() => { this.aacProfile = media.AacProfile.AAC_LC; })
        Button('AAC_HE_V2（省流）')
          .fontSize(12)
          .backgroundColor(this.aacProfile === media.AacProfile.AAC_HE_V2 ? '#1565C0' : '#ccc')
          .onClick(() => { this.aacProfile = media.AacProfile.AAC_HE_V2; })
      }
      .width('100%')
      .padding({ left: 12, right: 12 })

      Row({ space: 8 }) {
        Button('开始录音').enabled(!this.isRecording).onClick(() => this.startRecord())
        Button('停止').onClick(() => this.stopRecord())
      }
      .width('100%')
      .padding({ left: 12, right: 12 })

      Text('当前 profile：' + this.tierLabels[this.tier] + ' · rotation=' + this.rotation +
        '° · aacProfile=' + (this.aacProfile === media.AacProfile.AAC_LC ? 'LC' : 'HE_V2') +
        (this.hasRecording ? ' · 已存 ' + this.filePath : ''))
        .fontSize(12)
        .fontColor('#666')
        .padding(12)

      Text('关键点：profile 的所有取值都必须在 SDK 允许区间内，超出范围 prepare() 直接报 5400102。')
        .fontSize(12)
        .fontColor('#888')
        .padding(12)
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
