import { router } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';

// Chapter 32 §三 (skeleton): VIDEO recording with AVRecorder.
//
// AVRecorder video path:
//   createAVRecorder -> prepare(config) -> getInputSurface() -> start() -> stop()
//
// IMPORTANT: the surface that FEEDS AvRecorder must come from the camera
// (Camera Kit: cameraOutputCapability -> videoOutput configured with the
// AVRecorder input surface). The full Camera integration is the ch33 lesson.
// This page wires the AVRecorder side + the XComponent preview shell; the
// Camera -> AVRecorder surface bridge is marked with TODOs below.
@Entry
@Component
struct Ch32VideoRecord {
  private xcController: XComponentController = new XComponentController();
  private avRecorder: media.AVRecorder | undefined = undefined;
  private fileFd: number = -1;
  private surfaceId: string = '';

  @State recState: media.AVRecorderState = 'idle';
  @State isRecording: boolean = false;

  private async ensureCameraPermission(): Promise<boolean> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();
    const result = await atManager.requestPermissionsFromUser(
      context,
      ['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE'] as Permissions[]
    );
    return result.authResults.every((r: number) => r === 0);
  }

  async startVideoRecord(): Promise<void> {
    const granted: boolean = await this.ensureCameraPermission();
    if (!granted) {
      console.error('Camera/Microphone permission denied');
      return;
    }
    // Output file for the mp4 container.
    const filePath: string = getContext(this).filesDir + '/video_' + Date.now() + '.mp4';
    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
    this.fileFd = file.fd;

    try {
      this.avRecorder = await media.createAVRecorder();
      this.avRecorder.on('stateChange', (state: media.AVRecorderState) => {
        this.recState = state;
        this.isRecording = (state === 'started');
      });
      this.avRecorder.on('error', (err: BusinessError) => {
        console.error('AVRecorder error: ' + err.code + ' ' + err.message);
      });

      const profile: media.AVRecorderProfile = {
        audioBitrate: 48000,
        audioChannels: 2,
        audioCodec: media.CodecMimeType.AUDIO_AAC,
        audioSampleRate: 48000,
        videoBitrate: 2000000,
        videoCodec: media.CodecMimeType.VIDEO_AVC,
        videoFrameWidth: 640,
        videoFrameHeight: 480,
        videoFrameRate: 30,
        fileFormat: media.ContainerFormatType.CFT_MPEG_4
      };
      const config: media.AVRecorderConfig = {
        audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
        videoSourceType: media.VideoSourceType.VIDEO_SOURCE_TYPE_SURFACE_YUV,
        profile: profile,
        url: 'fd://' + this.fileFd,
        rotation: 0
      };
      await this.avRecorder.prepare(config);

      // The AVRecorder input surface MUST be handed to the Camera video output.
      // TODO(ch33): const inputSurface: string = await this.avRecorder.getInputSurface();
      //             connect `inputSurface` to camera.createVideoOutput(inputSurface).
      const inputSurface: string = await this.avRecorder.getInputSurface();
      console.info('AVRecorder input surface ready: ' + inputSurface);

      await this.avRecorder.start();
    } catch (error) {
      const err = error as BusinessError;
      console.error('startVideoRecord failed: ' + err.code + ' ' + err.message);
    }
  }

  private async stopVideoRecord(): Promise<void> {
    if (!this.avRecorder) {
      return;
    }
    await this.avRecorder.stop();
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
    Column({ space: 12 }) {
      Row() {
        Button('<')
          .fontSize(18)
          .width(40)
          .height(32)
          .backgroundColor(Color.Transparent)
          .fontColor('#317af7')
          .onClick(() => router.back())
        Text('② 相机录像')
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

      // XComponent SURFACE = the camera PREVIEW surface (same wiring as ch31 video player).
      XComponent({ id: 'video_recorder_xc', type: XComponentType.SURFACE, controller: this.xcController })
        .width('100%')
        .height(360)
        .onLoad(() => {
          this.surfaceId = this.xcController.getXComponentSurfaceId();
        })

      Row({ space: 8 }) {
        Button('开始录像')
          .enabled(!this.isRecording)
          .onClick(() => this.startVideoRecord())
        Button('停止录像')
          .enabled(this.isRecording)
          .onClick(() => this.stopVideoRecord())
      }
      .width('100%')
      .padding({ left: 12, right: 12 })

      Text('本页已搭好 AVRecorder 视频录制链路骨架；Camera 取流喂给 inputSurface 的完整实现在「第33篇 Camera」完成。')
        .fontSize(12)
        .fontColor('#888')
        .padding(12)
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
