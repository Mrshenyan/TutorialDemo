import { fileIo } from '@kit.CoreFileKit'
import { taskpool } from '@kit.ArkTS'
import { common } from '@kit.AbilityKit'
import { router } from '@kit.ArkUI'

// Reuse the same CPU-bound checksum from Demo 1, now applied to real file bytes.
@Concurrent
function crc32(buffer: Uint8Array): number {
  let crc: number = 0xFFFFFFFF
  for (let i: number = 0; i < buffer.length; i++) {
    crc ^= (buffer[i] & 0xFF)
    for (let j: number = 0; j < 8; j++) {
      if ((crc & 1) !== 0) {
        crc = (crc >>> 1) ^ 0xEDB88320
      } else {
        crc = crc >>> 1
      }
    }
  }
  return (crc ^ 0xFFFFFFFF) >>> 0
}

interface FileRecord {
  name: string
  size: number
  crc: number
}

@Entry
@Component
struct Ch37FileBatchDemo {
  private context: common.UIAbilityContext | null = null
  @State status: string = '先点「① 准备测试文件」生成一批文件'
  @State progress: number = 0
  @State elapsed: number = 0
  @State records: FileRecord[] = []

  aboutToAppear(): void {
    this.context = getContext(this) as common.UIAbilityContext
  }

  // 1) File management basics: create a sandbox subfolder and write N ~1MB files.
  prepareFiles(): void {
    if (!this.context) {
      return
    }
    const dir: string = `${this.context.filesDir}/ch37_batch`
    fileIo.mkdirSync(dir, true)
    for (let i: number = 0; i < 12; i++) {
      const path: string = `${dir}/sample_${i}.bin`
      const buf: Uint8Array = new Uint8Array(1024 * 1024)
      for (let k: number = 0; k < buf.length; k++) {
        buf[k] = ((i + 1) * k * 7) & 0xFF
      }
      const fd: number = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE).fd
      fileIo.writeSync(fd, buf.buffer)
      fileIo.closeSync(fd)
    }
    this.status = '已生成 12 个文件（每个 ~1MB），位于应用沙箱 ch37_batch/'
  }

  readFileBytes(path: string): Uint8Array {
    const stat = fileIo.statSync(path)
    const fd: number = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY).fd
    const buf: ArrayBuffer = new ArrayBuffer(stat.size)
    fileIo.readSync(fd, buf)
    fileIo.closeSync(fd)
    return new Uint8Array(buf)
  }

  // 2a) Sequential on the MAIN thread — blocks UI, progress bar won't move.
  runSequential(): void {
    if (!this.context) {
      return
    }
    const dir: string = `${this.context.filesDir}/ch37_batch`
    const names: string[] = fileIo.listFileSync(dir)
    const t0: number = Date.now()
    const out: FileRecord[] = []
    for (const name of names) {
      const bytes: Uint8Array = this.readFileBytes(`${dir}/${name}`)
      out.push({ name: name, size: bytes.length, crc: crc32(bytes) })
    }
    this.elapsed = Date.now() - t0
    this.records = out
    this.progress = 100
    this.status = `顺序校验完成（UI 卡顿），耗时 ${this.elapsed}ms`
  }

  // 2b) Concurrent via TaskPool — each file's checksum runs on a worker thread;
  // progress updates live because the main thread is free.
  async runConcurrent(): Promise<void> {
    if (!this.context) {
      return
    }
    const dir: string = `${this.context.filesDir}/ch37_batch`
    const names: string[] = fileIo.listFileSync(dir)
    const t0: number = Date.now()
    let done: number = 0
    this.progress = 0
    this.status = '任务池并发校验中…'
    const tasks: Promise<FileRecord>[] = names.map((name: string): Promise<FileRecord> => {
      const full: string = `${dir}/${name}`
      const bytes: Uint8Array = this.readFileBytes(full)
      const size: number = bytes.length
      return taskpool.execute(crc32, bytes).then((c: Object): FileRecord => {
        done++
        this.progress = Math.floor((done / names.length) * 100)
        return { name: name, size: size, crc: c as number }
      })
    })
    this.records = await Promise.all(tasks)
    this.elapsed = Date.now() - t0
    this.status = `并发校验完成（UI 流畅），耗时 ${this.elapsed}ms`
  }

  build() {
    Column({ space: 12 }) {
      Text('文件批量处理（沙箱 + TaskPool 并发）').fontSize(22).fontWeight(FontWeight.Bold)

      Button('① 准备测试文件（沙箱写）').width('90%').onClick(() => this.prepareFiles())
      Button('② 顺序校验（主线程·会卡）')
        .width('90%')
        .backgroundColor('#D32F2F')
        .onClick(() => this.runSequential())
      Button('③ 并发校验（任务池·顺滑）')
        .width('90%')
        .backgroundColor('#2E7D32')
        .onClick(() => this.runConcurrent())

      Text(this.status).width('90%').fontSize(12).fontColor('#666')

      Progress({ value: this.progress, total: 100 }).width('90%')

      Text(`耗时：${this.elapsed} ms`).width('90%').fontSize(12)

      List({ space: 6 }) {
        ForEach(this.records, (r: FileRecord) => {
          ListItem() {
            Row() {
              Text(r.name).fontSize(12).layoutWeight(1)
              Text(`${(r.size / 1024).toFixed(0)}KB`).fontSize(12).fontColor('#888').width(72)
              Text('0x' + r.crc.toString(16)).fontSize(12).fontFamily('monospace').width(120)
            }
            .width('100%')
            .padding(8)
            .backgroundColor('#F5F5F5')
            .borderRadius(6)
          }
        })
      }
      .width('90%')
      .layoutWeight(1)

      Button('返回').width('90%').onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Start)
  }
}
