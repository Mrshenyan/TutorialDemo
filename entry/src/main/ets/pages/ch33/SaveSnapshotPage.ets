import { router, componentSnapshot } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

// Demo ②: snapshot the current UI and save it into the system album.
// Pipeline: componentSnapshot.get -> image.ImagePacker.packToFile -> photoAccessHelper.showAssetsCreationDialog.
// showAssetsCreationDialog uses the system save dialog, so it needs NO user_grant permission.
@Entry
@Component
struct Ch33SaveSnapshotPage {
  @State status: string = '点击「生成并保存」把下方卡片存进系统相册';
  @State saving: boolean = false;

  async saveToGallery(): Promise<void> {
    if (this.saving) {
      return;
    }
    this.saving = true;
    this.status = '正在生成截图...';
    try {
      // 1. Snapshot the component marked with id('snapshotCard').
      const pixelMap: image.PixelMap = await componentSnapshot.get('snapshotCard');

      // 2. Encode the PixelMap into a temp JPEG file under the app cache dir.
      const context = getContext(this) as common.UIAbilityContext;
      const filePath: string = `${context.cacheDir}/snap_${Date.now()}.jpg`;
      const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      const packer = image.createImagePacker();
      await packer.packToFile(pixelMap, file.fd, { format: 'image/jpeg', quality: 98 });
      fileIo.closeSync(file.fd);

      // 3. Hand the temp file to the system save dialog; user confirms the destination.
      const helper = photoAccessHelper.getPhotoAccessHelper(context);
      const configs: Array<photoAccessHelper.PhotoCreationConfig> = [{
        fileNameExtension: 'jpg',
        photoType: photoAccessHelper.PhotoType.IMAGE
      }];
      const savedUris: Array<string> = await helper.showAssetsCreationDialog([filePath], configs);
      this.status = `已保存到系统相册，生成资产数: ${savedUris.length}`;
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      this.status = `保存失败: ${e.code} ${e.message}`;
    } finally {
      this.saving = false;
    }
  }

  build() {
    Column({ space: 16 }) {
      Text('componentSnapshot + 存库')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16 })

      // The snapshot target. componentSnapshot.get('snapshotCard') captures exactly this subtree.
      Column({ space: 10 }) {
        Text('跟着 cc 一起学鸿蒙开发')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        Text('第33篇 · 媒体库落地')
          .fontSize(16)
          .fontColor('#317af7')
        Text('这段文字会被截图存进你的相册')
          .fontSize(14)
          .fontColor('#888')
      }
      .id('snapshotCard')
      .width('85%')
      .padding(24)
      .backgroundColor('#0E1A28')
      .borderRadius(12)

      Text(this.status)
        .fontSize(13)
        .fontColor('#666')
        .width('90%')

      Button(this.saving ? '保存中...' : '生成并保存')
        .width('80%')
        .backgroundColor('#2E7D32')
        .enabled(!this.saving)
        .onClick(() => this.saveToGallery())

      Button('返回')
        .width('80%')
        .margin({ top: 8 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
