import { router } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';

// Chapter 32 §进阶三: post-recording processing with AVTranscoder (API 12+).
// Recording produces a file; AVTranscoder lets you re-encode / remux it afterwards,
// e.g. shrink a high-bitrate mp4 from ch32 into a smaller deliverable.
// Pipeline: createAVTranscoder -> set fdSrc/fdDst -> prepare(config) -> start -> release.
@Entry
@Component
struct Ch32Transcode {
  private transcoder: media.AVTranscoder | undefined = undefined;
  @State progress: number = 0;
  @State status: string = 'idle';
  @State outPath: string = '';

  async runTranscode(): Promise<void> {
    const ctx = getContext(this);
    const srcPath: string = ctx.filesDir + '/input.mp4';
    const dstPath: string = ctx.filesDir + '/output_' + Date.now() + '.mp4';
    this.status = 'preparing';
    this.progress = 0;
    try {
      const src = fileIo.openSync(srcPath, fileIo.OpenMode.READ_ONLY);
      const dst = fileIo.openSync(dstPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      const stat = fileIo.statSync(srcPath);
      this.transcoder = await media.createAVTranscoder();
      this.transcoder.fdSrc = { fd: src.fd, offset: 0, length: stat.size };
      this.transcoder.fdDst = dst.fd;
      this.transcoder.on('progressUpdate', (p: number) => {
        this.progress = p;
      });
      this.transcoder.on('error', (e: BusinessError) => {
        this.status = 'error ' + e.code;
      });
      const config: media.AVTranscoderConfig = {
        fileFormat: media.ContainerFormatType.CFT_MPEG_4,
        audioCodec: media.CodecMimeType.AUDIO_AAC,
        videoCodec: media.CodecMimeType.VIDEO_AVC,
        videoBitrate: 2000000,
        audioBitrate: 96000
      };
      await this.transcoder.prepare(config);
      this.status = 'transcoding';
      await this.transcoder.start();
      this.status = 'done';
      this.outPath = dstPath;
    } catch (error) {
      const err = error as BusinessError;
      this.status = 'error ' + err.code + ' ' + err.message;
      console.error('transcode failed: ' + err.code + ' ' + err.message);
    } finally {
      if (this.transcoder) {
        await this.transcoder.release();
        this.transcoder = undefined;
      }
    }
  }

  aboutToDisappear(): void {
    if (this.transcoder) {
      this.transcoder.release();
      this.transcoder = undefined;
    }
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Button('<')
          .fontSize(18)
          .width(40)
          .height(32)
          .backgroundColor(Color.Transparent)
          .fontColor('#317af7')
          .onClick(() => router.back())
        Text('③ 录制后转码')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: 12, top: 6, bottom: 6 })
      .backgroundColor('#F5F5F5')

      Text('把 ch32 录的 mp4 命名为 input.mp4 放进应用沙箱（DevEco 设备文件浏览器或 hdc file send），点下方按钮转码为更小体积的 output.mp4。')
        .fontSize(13)
        .fontColor('#666')
        .padding(12)

      Button('开始转码（input.mp4 → output.mp4）')
        .width('85%')
        .backgroundColor('#1565C0')
        .onClick(() => this.runTranscode())

      // Progress bar: progress is 0..100
      Column() {
        Row()
          .width(this.progress + '%')
          .height(20)
          .borderRadius(10)
          .backgroundColor('#1565C0')
      }
      .width('85%')
      .height(20)
      .borderRadius(10)
      .backgroundColor('#EEEEEE')
      .align(Alignment.Start)

      Text('进度：' + this.progress + '% · 状态：' + this.status)
        .fontSize(13)
        .fontColor('#666')

      if (this.outPath !== '') {
        Text('已生成：' + this.outPath)
          .fontSize(12)
          .fontColor('#2E7D32')
          .padding(12)
      }

      Text('AVTranscoder 与 AVRecorder 同属 @ohos.multimedia.media，但职责不同：' +
        '前者“生产”新文件，后者“加工”已有文件。两者都不支持运行时改参数。')
        .fontSize(12)
        .fontColor('#888')
        .padding(12)
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
