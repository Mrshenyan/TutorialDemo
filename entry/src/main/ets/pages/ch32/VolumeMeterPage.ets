import { router } from '@kit.ArkUI';
import { audio } from '@kit.AudioKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';

// Chapter 32 §进阶二: real-time microphone level meter. AVRecorder gives you a file;
// it does NOT give you live audio samples. To drive a "voice waveform" UI we open a
// raw PCM capturer (AudioCapturer) and read its 'readData' buffers, computing RMS -> dB
// on the fly. This is the "soul" of any voice-recorder app and goes beyond ch32.
@Entry
@Component
struct Ch32VolumeMeter {
  private capturer: audio.AudioCapturer | undefined = undefined;
  @State db: number = -60; // dBFS-ish: -60 silent .. 0 loud
  @State isListening: boolean = false;

  private async ensureMicPermission(): Promise<boolean> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();
    const result = await atManager.requestPermissionsFromUser(
      context,
      ['ohos.permission.MICROPHONE'] as Permissions[]
    );
    return result.authResults.every((r: number) => r === 0);
  }

  async startMeter(): Promise<void> {
    const granted: boolean = await this.ensureMicPermission();
    if (!granted) {
      console.error('Microphone permission denied');
      return;
    }
    const options: audio.AudioCapturerOptions = {
      streamInfo: {
        samplingRate: 48000,
        channels: audio.AudioChannel.CHANNEL_2,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      },
      capturerInfo: {
        source: audio.SourceType.SOURCE_TYPE_MIC,
        capturerFlags: 0
      }
    };
    try {
      this.capturer = await audio.createAudioCapturer(options);
      this.capturer.on('readData', (buffer: ArrayBuffer) => {
        this.computeDb(buffer);
      });
      await this.capturer.start();
      this.isListening = true;
    } catch (error) {
      const err = error as BusinessError;
      console.error('startMeter failed: ' + err.code + ' ' + err.message);
    }
  }

  // Convert a PCM chunk to an RMS-based dB value, clamped to [-60, 0].
  private computeDb(buffer: ArrayBuffer): void {
    const samples = new Int16Array(buffer);
    let sum: number = 0;
    for (let i = 0; i < samples.length; i++) {
      const v: number = samples[i] / 32768;
      sum += v * v;
    }
    const rms: number = Math.sqrt(sum / Math.max(1, samples.length));
    let db: number = 20 * Math.log10(rms + 1e-6);
    if (db < -60) {
      db = -60;
    }
    this.db = db;
  }

  private async stopMeter(): Promise<void> {
    if (this.capturer) {
      try {
        await this.capturer.stop();
        await this.capturer.release();
      } catch (error) {
        const err = error as BusinessError;
        console.error('stopMeter failed: ' + err.code);
      }
      this.capturer = undefined;
    }
    this.isListening = false;
    this.db = -60;
  }

  aboutToDisappear(): void {
    if (this.capturer) {
      this.capturer.release();
      this.capturer = undefined;
    }
  }

  build() {
    Column({ space: 18 }) {
      Row() {
        Button('<')
          .fontSize(18)
          .width(40)
          .height(32)
          .backgroundColor(Color.Transparent)
          .fontColor('#317af7')
          .onClick(() => router.back())
        Text('② 实时麦克风音量条')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: 12, top: 6, bottom: 6 })
      .backgroundColor('#F5F5F5')

      Text('对着麦克风说话，看音量条实时跳动')
        .fontSize(14)
        .fontColor('#666')

      // Big dB readout
      Text(this.db.toFixed(1) + ' dB')
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.db > -20 ? '#E53935' : (this.db > -45 ? '#FB8C00' : '#43A047'))

      // Level bar: width scales with (db+60)/60 in [-60,0] -> [0%,100%]
      Column() {
        Row()
          .width(((this.db + 60) / 60 * 100) + '%')
          .height(24)
          .borderRadius(12)
          .backgroundColor(this.db > -20 ? '#E53935' : (this.db > -45 ? '#FB8C00' : '#43A047'))
      }
      .width('85%')
      .height(24)
      .borderRadius(12)
      .backgroundColor('#EEEEEE')
      .align(Alignment.Start)

      Row({ space: 8 }) {
        Button(this.isListening ? '停止监听' : '开始监听')
          .backgroundColor('#2E7D32')
          .onClick(() => {
            if (this.isListening) {
              this.stopMeter();
            } else {
              this.startMeter();
            }
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12 })

      Text('原理：AudioCapturer 拿到的是 16bit PCM 原始采样，按帧算 RMS 再转 dB。' +
        'AVRecorder 不提供这层数据，所以实时音量必须另开一路 AudioCapturer。')
        .fontSize(12)
        .fontColor('#888')
        .padding(12)
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
