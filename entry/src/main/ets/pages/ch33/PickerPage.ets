import { router } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';

// Demo ①: pick an image/video from the system album with PhotoViewPicker.
// PhotoViewPicker is launched by the SYSTEM and brokers authorization for you,
// so you do NOT need to declare any permission in module.json5.
@Entry
@Component
struct Ch33PickerPage {
  @State imageUri: string = '';
  @State videoUri: string = '';
  @State tip: string = '点击下方按钮，从相册挑选媒体';

  // Pick an image and preview it with the <Image> component.
  async pickImage(): Promise<void> {
    try {
      const picker = new photoAccessHelper.PhotoViewPicker();
      const result: photoAccessHelper.PhotoSelectResult = await picker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      });
      if (result.photoUris.length > 0) {
        this.imageUri = result.photoUris[0];
        this.videoUri = '';
        this.tip = '已挑选图片（系统授权，无需声明权限）';
      } else {
        this.tip = '未选择任何内容';
      }
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      this.tip = `挑选失败: ${e.code} ${e.message}`;
    }
  }

  // Pick a video and play it with the <Video> component.
  async pickVideo(): Promise<void> {
    try {
      const picker = new photoAccessHelper.PhotoViewPicker();
      const result: photoAccessHelper.PhotoSelectResult = await picker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE,
        maxSelectNumber: 1
      });
      if (result.photoUris.length > 0) {
        this.videoUri = result.photoUris[0];
        this.imageUri = '';
        this.tip = '已挑选视频，可直接播放';
      } else {
        this.tip = '未选择任何内容';
      }
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      this.tip = `挑选失败: ${e.code} ${e.message}`;
    }
  }

  build() {
    Column({ space: 12 }) {
      Text('PhotoViewPicker · 从相册挑选')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16 })

      Text(this.tip)
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      Button('挑选图片')
        .width('80%')
        .onClick(() => this.pickImage())

      Button('挑选视频')
        .width('80%')
        .backgroundColor('#2E7D32')
        .onClick(() => this.pickVideo())

      if (this.imageUri !== '') {
        Image(this.imageUri)
          .width('90%')
          .height(220)
          .objectFit(ImageFit.Contain)
          .borderRadius(8)
          .margin({ top: 8 })
      }

      if (this.videoUri !== '') {
        Video({ src: this.videoUri })
          .width('90%')
          .height(220)
          .margin({ top: 8 })
      }

      Button('返回')
        .width('80%')
        .margin({ top: 12 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
