import { router } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { common, abilityAccessCtrl } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

// Chapter 27 §2/§3: finger signature pad.
// - Draw with onTouch: TouchEvent exposes absolute vp coordinates, so the
//   ink follows the finger exactly (no coordinate conversion needed).
// - Toolbar: clear / color presets / stroke width presets.
// - Save to gallery with TWO approaches:
//   1) No permission: photoAccessHelper.showAssetsCreationDialog (API 12+)
//      lets the user pick the target album via a system dialog.
//   2) With permission: request ohos.permission.WRITE_IMAGEVIDEO, then
//      photoAccessHelper.createAsset writes into the gallery directly.
@Entry
@Component
struct Ch27Signature {
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  @State brushColor: string = '#333333';
  @State brushWidth: number = 4;
  @State saveHint: string = '';
  private drawing: boolean = false;
  private lastX: number = 0;
  private lastY: number = 0;
  private canvasWidth: number = 0;
  private canvasHeight: number = 0;
  private colors: string[] = ['#333333', '#1E88E5', '#E53935', '#43A047'];

  // Draw ink from the finger position. Each Move paints a short segment and
  // starts a fresh path, so color/width changes take effect immediately.
  private handleTouch(event: TouchEvent): void {
    if (event.touches.length === 0) {
      return;
    }
    const touch = event.touches[0];
    const x = touch.x;
    const y = touch.y;
    if (event.type === TouchType.Down) {
      this.drawing = true;
      this.lastX = x;
      this.lastY = y;
      this.ctx.beginPath();
      this.ctx.moveTo(x, y);
    } else if (event.type === TouchType.Move && this.drawing) {
      this.ctx.lineTo(x, y);
      this.ctx.strokeStyle = this.brushColor;
      this.ctx.lineWidth = this.brushWidth;
      this.ctx.stroke();
      this.ctx.beginPath();
      this.ctx.moveTo(x, y);
      this.lastX = x;
      this.lastY = y;
    } else if (event.type === TouchType.Up) {
      this.drawing = false;
      this.lastX = 0;
      this.lastY = 0;
    }
  }

  private clearCanvas(): void {
    this.ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  // Export the canvas bitmap to a sandbox PNG file, return its file path.
  private async dumpCanvasToFile(): Promise<string> {
    try {
      const dataUrl = this.ctx.toDataURL('image/png');
      const parts = dataUrl.split(',');
      const base64 = parts.length > 1 ? parts[1] : '';
      const helper = new util.Base64Helper();
      const bytes: Uint8Array = helper.decodeSync(base64);
      // writeSync expects ArrayBuffer, so read the underlying buffer from the Uint8Array.
      const buffer: ArrayBuffer = bytes.buffer as ArrayBuffer;

      const context = getContext(this) as common.UIAbilityContext;
      const filePath = `${context.filesDir}/signature_${Date.now()}.png`;
      console.log(`ccTestShow Path : ${filePath}`)
      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      console.log(`ccTestShow  ${bytes}`)
      fileIo.writeSync(file.fd, buffer)
      console.log(`ccTestShow  ${file.fd}`)
      fileIo.closeSync(file);
      return filePath;
    } catch (e) {
      const err = e as BusinessError;
      console.log(`ccTestShow 保存失败 catch ${err.message} code: ${err.code}`)
      this.saveHint = `导出图片失败: ${err.message}`;
      return '';
    }
  }

  // Save WITHOUT any permission: a system dialog lets the user pick the album.
  private async saveNoPermission(): Promise<void> {
    const filePath = await this.dumpCanvasToFile();
    if (filePath.length === 0) {
      return;
    }
    const context = getContext(this) as common.UIAbilityContext;
    const helper = photoAccessHelper.getPhotoAccessHelper(context);
    try {
      const uris: Array<string> = [fileUri.getUriFromPath(filePath)];
      const config: photoAccessHelper.PhotoCreationConfig = {
        title: 'signature',
        fileNameExtension: 'png',
        photoType: photoAccessHelper.PhotoType.IMAGE,
      };
      const result: Array<string> = await helper.showAssetsCreationDialog(uris, [config]);
      this.saveHint = result.length > 0 ? '已保存到相册（免权限方案，无需授权）' : '已取消（免权限方案）';
      for(let i=0;i<result.length;i++){
        console.log(`ccTestShow  ${result[i]}`)
      }
    } catch (e) {
      const err = e as BusinessError;
      this.saveHint = `保存失败: ${err.message}`;
    }
  }

  // Save WITH permission: request WRITE_IMAGEVIDEO first, then createAsset.
  private async saveWithPermission(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();
    try {
      const result = await atManager.requestPermissionsFromUser(context, ['ohos.permission.WRITE_IMAGEVIDEO']);
      if (result.authResults[0] !== 0) {
        this.saveHint = '未获得相册写入权限，保存失败';
        return;
      }
    } catch (e) {
      const err = e as BusinessError;
      this.saveHint = `权限申请失败: ${err.message}`;
      return;
    }
    const filePath = await this.dumpCanvasToFile();
    if (filePath.length === 0) {
      return;
    }
    const helper = photoAccessHelper.getPhotoAccessHelper(context);
    try {
      // createAsset creates an EMPTY asset and returns its URI;
      // we then copy our PNG bytes into it via file descriptors.
      const assetUri: string = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
      const srcFile = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY);
      const destFile = fileIo.openSync(assetUri, fileIo.OpenMode.READ_WRITE);
      fileIo.copyFileSync(srcFile.fd, destFile.fd);
      fileIo.closeSync(srcFile);
      fileIo.closeSync(destFile);
      this.saveHint = `已写入相册（权限方案）: ${assetUri}`;
    } catch (e) {
      const err = e as BusinessError;
      this.saveHint = `保存失败: ${err.message}`;
    }
  }

  build() {
    Column({ space: 12 }) {
      Text('手势签名板')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Text('手指在白色画板签名；下方可换颜色/粗细、清空、保存到相册')
        .fontSize(13)
        .fontColor('#666')

      Canvas(this.ctx)
        .width('92%')
        .layoutWeight(1)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .onReady(() => {
          this.ctx.lineCap = 'round';
          this.ctx.lineJoin = 'round';
        })
        .onAreaChange((oldValue: Area, newValue: Area) => {
          this.canvasWidth = Number(newValue.width);
          this.canvasHeight = Number(newValue.height);
        })
        .onTouch((event: TouchEvent) => this.handleTouch(event))

      // brush color presets
      Row({ space: 12 }) {
        ForEach(this.colors, (c: string) => {
          Circle({ width: 28, height: 28 })
            .fill(c)
            .stroke(this.brushColor === c ? '#FF9800' : '#CCCCCC')
            .strokeWidth(this.brushColor === c ? 3 : 1)
            .onClick(() => {
              this.brushColor = c;
            })
        }, (c: string) => c)
      }
      .margin({ top: 8 })

      // brush width presets
      Row({ space: 12 }) {
        Button('细')
          .fontSize(14)
          .backgroundColor(this.brushWidth === 2 ? '#FF9800' : '#3F51B5')
          .onClick(() => {
            this.brushWidth = 2;
          })
        Button('中')
          .fontSize(14)
          .backgroundColor(this.brushWidth === 4 ? '#FF9800' : '#3F51B5')
          .onClick(() => {
            this.brushWidth = 4;
          })
        Button('粗')
          .fontSize(14)
          .backgroundColor(this.brushWidth === 8 ? '#FF9800' : '#3F51B5')
          .onClick(() => {
            this.brushWidth = 8;
          })
      }

      Row({ space: 8 }) {
        Button('清空')
          .layoutWeight(1)
          .backgroundColor('#9E9E9E')
          .onClick(() => this.clearCanvas())
        Button('免权限保存')
          .layoutWeight(1)
          .backgroundColor('#43A047')
          .onClick(() => this.saveNoPermission())
        Button('权限保存')
          .layoutWeight(1)
          .backgroundColor('#1E88E5')
          .onClick(() => this.saveWithPermission())
      }
      .width('92%')

      if (this.saveHint.length > 0) {
        Text(this.saveHint)
          .fontSize(13)
          .fontColor('#333')
          .padding(8)
      }

      Button('返回')
        .width('80%')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(12)
  }
}
