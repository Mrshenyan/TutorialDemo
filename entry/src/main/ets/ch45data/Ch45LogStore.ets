import { fileIo } from '@kit.CoreFileKit'
import { util } from '@kit.ArkTS'

// Chapter 45 - file logging helper.
// hilog goes to the system log ring buffer, which is only visible through
// hdc. Anything you want to keep after the buffer rolls over (or ship to your
// own backend) needs a private on-device file. This class wraps the sync fs
// API because logging must never block the UI thread with a promise
// round-trip.
//
// SDK reality check (API 12+ / DevEco 2026): the old `fs` namespace is gone.
// The module @ohos.file.fs now default-exports as `fileIo`, surfaced through
// @kit.CoreFileKit. Two signature changes matter here:
//   - openSync returns a File object (use .fd), not a bare number.
//   - writeSync accepts a plain string (encoded UTF-8 by the SDK), so Chinese
//     log lines need no manual TextEncoder dance.
//
// Strict-mode notes:
//   - No catch type annotations allowed: plain `catch (e)`.
export class Ch45LogStore {
  private static readonly LOG_DIR = 'logs'
  private static readonly LOG_FILE = 'ch45.log'

  // Absolute path of the log file inside the app sandbox (el2 level, removed
  // together with the app on uninstall).
  static logPath(): string {
    return Ch45LogStore.dirPath() + '/' + Ch45LogStore.LOG_FILE
  }

  private static dirPath(): string {
    return getContext().filesDir + '/' + Ch45LogStore.LOG_DIR
  }

  private static ensureDir(): void {
    const dir: string = Ch45LogStore.dirPath()
    if (!fileIo.accessSync(dir)) {
      fileIo.mkdirSync(dir, true)
    }
  }

  private static nowStamp(): string {
    const d: Date = new Date()
    const pad = (n: number): string => (n < 10 ? '0' + n : '' + n)
    return pad(d.getHours()) + ':' + pad(d.getMinutes()) + ':' + pad(d.getSeconds())
  }

  // Append one line. Newlines inside the message are collapsed so a crafted
  // message cannot forge extra log lines (log injection).
  static append(level: string, tag: string, msg: string): boolean {
    const clean: string = msg.replace(/\n/g, ' ')
    const line: string = '[' + level + '] ' + Ch45LogStore.nowStamp() + ' ' + tag + ': ' + clean + '\n'
    try {
      Ch45LogStore.ensureDir()
      const file = fileIo.openSync(Ch45LogStore.logPath(),
        fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.APPEND)
      fileIo.writeSync(file.fd, line)
      fileIo.closeSync(file)
      return true
    } catch (e) {
      return false
    }
  }

  // Read the tail of the file. readSync has no "read to EOF" variant, so size
  // the buffer from statSync first, then decode UTF-8 back to a string.
  static readTail(maxLines: number): string[] {
    try {
      if (!fileIo.accessSync(Ch45LogStore.logPath())) {
        return []
      }
      const size: number = fileIo.statSync(Ch45LogStore.logPath()).size
      if (size <= 0) {
        return []
      }
      const file = fileIo.openSync(Ch45LogStore.logPath(), fileIo.OpenMode.READ_ONLY)
      const buf: ArrayBuffer = new ArrayBuffer(size)
      const read: number = fileIo.readSync(file.fd, buf)
      fileIo.closeSync(file)
      const dec: util.TextDecoder = new util.TextDecoder()
      const text: string = dec.decodeToString(new Uint8Array(buf.slice(0, read)))
      const lines: string[] = text.split('\n').filter((l: string) => l.length > 0)
      return lines.slice(Math.max(0, lines.length - maxLines))
    } catch (e) {
      return []
    }
  }

  static fileSize(): number {
    try {
      if (!fileIo.accessSync(Ch45LogStore.logPath())) {
        return 0
      }
      return fileIo.statSync(Ch45LogStore.logPath()).size
    } catch (e) {
      return 0
    }
  }

  static clear(): boolean {
    try {
      if (fileIo.accessSync(Ch45LogStore.logPath())) {
        fileIo.unlinkSync(Ch45LogStore.logPath())
      }
      return true
    } catch (e) {
      return false
    }
  }
}
