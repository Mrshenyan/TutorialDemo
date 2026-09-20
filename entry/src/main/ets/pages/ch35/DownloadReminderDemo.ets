import { router } from '@kit.ArkUI'
import { common, WantAgent, wantAgent } from '@kit.AbilityKit'
import { backgroundTaskManager, reminderAgentManager } from '@kit.BackgroundTasksKit'
import { request, BusinessError } from '@kit.BasicServicesKit'
import { fileIo } from '@kit.CoreFileKit'

/**
 * 后台下载 demo（长时任务 · DATA_TRANSFER）+ 下载完成代理提醒
 *
 * 关键点：
 * 1. module.json5 的 EntryAbility 需声明 backgroundModes: ["dataTransfer"]，
 *    且已声明权限 ohos.permission.KEEP_BACKGROUND_RUNNING。
 * 2. 用 @ohos.request（@kit.BasicServicesKit）的 downloadFile 做下载，
 *    DownloadConfig.background = true 允许系统下发后台下载通知。
 * 3. 下载完成（on('complete')）后：先停长时任务，再发布一条「下载完成」代理提醒，
 *    把 ch34 的两种后台能力串起来——即使应用被杀，提醒照样弹。
 * 4. 代理提醒仍然受 AGC「代理提醒开放能力」配额墙限制（详见第 34 篇的 1700002 排查），
 *    所以发布前先 clearAllReminders() 兜底，并对 1700002 单独提示去 AGC 申请。
 */
@Entry
@Component
struct Ch35DownloadReminderDemo {
  @State log: string = '尚未开始后台下载'
  @State progress: number = 0
  @State downloading: boolean = false
  private taskStarted: boolean = false
  private downloadTask?: request.DownloadTask

  private async buildWantAgent(): Promise<WantAgent> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    return await wantAgent.getWantAgent({
      wants: [
        {
          bundleName: context.abilityInfo.bundleName,
          abilityName: 'EntryAbility'
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0
    })
  }

  // 发布前先清掉本应用全部历史提醒，避免反复点击累积到上限（1700002）
  private async clearAllReminders(): Promise<void> {
    try {
      await reminderAgentManager.cancelAllReminders()
    } catch (err) {
      const e: BusinessError = err as BusinessError
      if (e.code !== 1700003) { // 1700003 = 本来就没有可取消的，忽略
        console.error(`cancelAllReminders 失败: ${e.code} ${e.message}`)
      }
    }
  }

  async startDownload(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    this.downloading = true
    this.progress = 0

    // 1) 启动长时任务 DATA_TRANSFER，声明「后台在传数据」
    try {
      const agent: WantAgent = await this.buildWantAgent()
      await backgroundTaskManager.startBackgroundRunning(
        context,
        backgroundTaskManager.BackgroundMode.DATA_TRANSFER,
        agent
      )
      this.taskStarted = true
    } catch (err) {
      const e: BusinessError = err as BusinessError
      this.log = `启动长时任务失败(${e.code}): ${e.message}。请确认 backgroundModes 含 dataTransfer 且已声明 KEEP_BACKGROUND_RUNNING`
      this.downloading = false
      return
    }

    // 2) 下载到沙箱 filesDir 下
    const filePath: string = `${context.filesDir}/ch35_download.bin`
    // 关键修复：request 不会对已存在的 filePath 自动覆盖，二次下载会报 13400002「File exists」。
    // 下载前若目标文件已存在，先删掉旧文件，保证每次点击都能重新下载（见 @ohos.request 文档 error code 2/13400002）。
    try {
      fileIo.unlinkSync(filePath)
    } catch (e) {
      // 文件不存在时 unlinkSync 会抛错（No such file），属正常情况，忽略即可
    }
    const config: request.DownloadConfig = {
      // 公开测试下载链接（jsDelivr 公共 CDN，HTTPS、国内可达、返回二进制文件可直接落盘）。
      // 若仍报 err=8（地址不可达/网络问题），可换国内镜像备用：
      // https://registry.npmmirror.com/jquery/3.7.1/files/dist/jquery.min.js
      url: 'https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js',
      filePath: filePath,
      background: true
    }

    try {
      const task: request.DownloadTask = await request.downloadFile(context, config)
      this.downloadTask = task

      task.on('progress', (receivedSize: number, totalSize: number) => {
        this.progress = totalSize > 0 ? Math.floor((receivedSize / totalSize) * 100) : 0
        this.log = `下载中：${this.progress}%`
      })
      task.on('complete', () => {
        this.log = `下载完成，文件已保存到 ${filePath}`
        this.onDownloadComplete()
      })
      task.on('fail', (err: number) => {
        this.log = `下载失败，错误码 ${err}`
        this.cleanupTask()
      })
    } catch (err) {
      const e: BusinessError = err as BusinessError
      this.log = `下载启动失败(${e.code}): ${e.message}`
      this.cleanupTask()
    }
  }

  // 下载完成后：停长时任务 -> 发「下载完成」代理提醒
  private async onDownloadComplete(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    if (this.taskStarted) {
      await backgroundTaskManager.stopBackgroundRunning(context)
      this.taskStarted = false
    }
    this.downloading = false
    this.downloadTask = undefined

    // 发布代理提醒：用倒计时类型（triggerTimeInSeconds=1）实现「几乎即时」的完成通知
    await this.clearAllReminders()
    const reminder: reminderAgentManager.ReminderRequestTimer = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
      triggerTimeInSeconds: 1,
      title: '下载完成',
      content: '你后台下载的文件已就绪，点击查看～',
      actionButton: [
        { title: '知道了', type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE }
      ]
    }

    try {
      await reminderAgentManager.publishReminder(reminder)
      this.log += '\n已发布「下载完成」代理提醒（应用被杀也能收到）。'
    } catch (err) {
      const e: BusinessError = err as BusinessError
      if (e.code === 1700002) {
        this.log += '\n发布提醒失败 1700002：普通应用默认代理提醒额度为 0，需在华为 AGC 走「代理提醒开放能力申请」拿到配额（详见第 34 篇）。'
      } else if (e.code === 1700001) {
        this.log += '\n发布提醒失败 1700001：本应用通知未开启，请到系统设置开启或调用 Notification.requestEnableNotification()。'
      } else {
        this.log += `\n发布提醒失败(${e.code}): ${e.message}`
      }
    }
  }

  private cleanupTask(): void {
    if (this.taskStarted) {
      const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
      backgroundTaskManager.stopBackgroundRunning(context).catch(() => {})
      this.taskStarted = false
    }
    this.downloading = false
    this.downloadTask = undefined
  }

  build() {
    Column({ space: 14 }) {
      Text('后台下载（长时任务 · DATA_TRANSFER）+ 完成代理提醒')
        .fontSize(20).fontWeight(FontWeight.Bold).margin({ top: 16 })

      Button(this.downloading ? '下载中…' : '开始后台下载')
        .width('80%')
        .backgroundColor('#2E7D32')
        .enabled(!this.downloading)
        .onClick(() => this.startDownload())

      if (this.progress > 0) {
        Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
          .width('80%')
        Text(`${this.progress}%`).fontSize(14).fontColor('#333')
      }

      Text(this.log)
        .fontSize(14).fontColor('#333')
        .width('90%').backgroundColor('#F2F2F2')
        .padding(12).borderRadius(8)

      Button('返回').width('80%').margin({ top: 12 })
        .onClick(() => router.back())
    }
    .width('100%').height('100%').padding(16)
  }
}
