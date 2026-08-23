import { router } from '@kit.ArkUI';

// Chapter 27 §1: Canvas basics + a PanGesture drawing demo.
// - Top canvas: static drawing with vp coordinates (line / circle / rect / text).
// - Bottom canvas: paint by dragging, driven by the PanGesture system.
// Note: GestureEvent only exposes OFFSETS relative to the gesture start point,
// not absolute coordinates, so the gesture demo draws relative to the canvas
// center. That is why the signature pad (§2) uses onTouch instead.
@Entry
@Component
struct Ch27CanvasBasic {
  private staticSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private staticCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.staticSettings);
  private gestureSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private gestureCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.gestureSettings);
  private gestureLastX: number = 0;
  private gestureLastY: number = 0;

  build() {
    Column({ space: 12 }) {
      Text('Canvas 基础 + PanGesture')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Text('上半：静态绘制（直线/圆/矩形/文字，坐标单位 vp）')
        .fontSize(13)
        .fontColor('#666')

      Canvas(this.staticCtx)
        .width('92%')
        .height(180)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .onReady(() => {
          const ctx = this.staticCtx;
          // light grid to make coordinates visible
          ctx.strokeStyle = '#E0E0E0';
          ctx.lineWidth = 1;
          for (let x = 0; x <= 340; x += 34) {
            ctx.beginPath();
            ctx.moveTo(x, 0);
            ctx.lineTo(x, 180);
            ctx.stroke();
          }
          // straight line
          ctx.strokeStyle = '#1E88E5';
          ctx.lineWidth = 3;
          ctx.beginPath();
          ctx.moveTo(10, 30);
          ctx.lineTo(200, 30);
          ctx.stroke();
          // circle
          ctx.strokeStyle = '#E53935';
          ctx.beginPath();
          ctx.arc(250, 60, 30, 0, Math.PI * 2);
          ctx.stroke();
          // filled rectangle
          ctx.fillStyle = '#FDD835';
          ctx.fillRect(10, 85, 90, 55);
          // text
          ctx.fillStyle = '#333333';
          ctx.font = '16vp sans-serif';
          ctx.fillText('Canvas 文字', 130, 115);
        })

      Text('下半：PanGesture 拖动涂鸦（从中心出发，offset 相对手势起点）')
        .fontSize(13)
        .fontColor('#666')

      Canvas(this.gestureCtx)
        .width('92%')
        .height(180)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .onReady(() => {
          const ctx = this.gestureCtx;
          ctx.fillStyle = '#EEEEEE';
          ctx.fillRect(0, 0, 320, 180);
          ctx.fillStyle = '#999999';
          ctx.font = '14vp sans-serif';
          ctx.fillText('按住拖动试试', 118, 92);
        })
        .gesture(PanGesture({ fingers: 1 })
          .onActionStart((event: GestureEvent) => {
            // only relative offsets are available -> anchor at canvas center
            const ctx = this.gestureCtx;
            this.gestureLastX = 160 + event.offsetX;
            this.gestureLastY = 90 + event.offsetY;
            ctx.strokeStyle = '#1E88E5';
            ctx.lineWidth = 4;
            ctx.lineCap = 'round';
            ctx.beginPath();
            ctx.moveTo(this.gestureLastX, this.gestureLastY);
          })
          .onActionUpdate((event: GestureEvent) => {
            const ctx = this.gestureCtx;
            const x = 160 + event.offsetX;
            const y = 90 + event.offsetY;
            ctx.lineTo(x, y);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(x, y);
          }))

      Text('提示：GestureEvent 只有相对偏移、拿不到绝对坐标；精确笔迹请用 onTouch（见签名板）')
        .fontSize(13)
        .fontColor('#E53935')
        .padding({ left: 12, right: 12 })

      Button('去签名板')
        .width('80%')
        .onClick(() => router.pushUrl({ url: 'pages/ch27/SignatureDemo' } as router.RouterOptions))

      Button('返回')
        .width('80%')
        .margin({ top: 4 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(12)
  }
}
