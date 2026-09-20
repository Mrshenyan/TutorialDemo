import { router } from '@kit.ArkUI'
import { common, WantAgent, wantAgent } from '@kit.AbilityKit'
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'
import { media } from '@kit.MediaKit'
import { avSession } from '@kit.AVSessionKit'
import { audio } from '@kit.AudioKit'
import { BusinessError } from '@kit.BasicServicesKit'

/**
 * 后台音频播放 demo（长时任务 · AUDIO_PLAYBACK）— 进阶版
 *
 * 在基础版（长时任务保活）之上，补齐两个"上架级"能力：
 * 1) AVSession 媒体会话：接入后锁屏 / 控制中心能显示曲目并播放/暂停/停止，
 *    否则后台音频在系统看来是"不完整"的，可能被回收或上架审核不通过。
 * 2) 音频焦点 / 打断管理：通过 AVPlayer 的 audioInterrupt 事件处理来电、
 *    其他 App 抢焦点时的暂停/恢复/降音量，避免多个 App 声音打架。
 *
 * 前置：module.json5 的 EntryAbility 需声明 backgroundModes: ["audioPlayback"]
 *      且已声明权限 ohos.permission.KEEP_BACKGROUND_RUNNING（第 34 篇已加）。
 */
@Entry
@Component
struct Ch35AudioPlaybackDemo {
  @State log: string = '尚未开始后台播放'
  @State playing: boolean = false
  @State sessionActive: boolean = false
  private avPlayer?: media.AVPlayer
  private avSession?: avSession.AVSession
  private taskStarted: boolean = false
  // 记录打断前是否在播放，用于焦点归还时决定是否自动恢复
  private playingBeforeInterrupt: boolean = false

  // 构造点击常驻通知后回跳本应用的 WantAgent（与第 34 篇长时任务一致）
  private async buildWantAgent(): Promise<WantAgent> {
    const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
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

  // 把当前播放状态同步给媒体会话（锁屏据此显示播放/暂停图标）
  private updateSessionState(state: avSession.PlaybackState): void {
    this.avSession?.setAVPlaybackState({
      state: state,
      position: { elapsedTime: 0, updateTime: 0 }
    }).catch((err: BusinessError) => {
      console.error(`setAVPlaybackState failed: ${err.code} ${err.message}`)
    })
  }

  async startPlayback(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

    // 1) 先启动长时任务，否则切后台会被系统冻结，播放中断
    try {
      const agent: WantAgent = await this.buildWantAgent()
      await backgroundTaskManager.startBackgroundRunning(
        context,
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,
        agent
      )
      this.taskStarted = true
    } catch (err) {
      const e: BusinessError = err as BusinessError
      this.log = `启动长时任务失败(${e.code}): ${e.message}。请确认 backgroundModes 含 audioPlayback 且已声明 KEEP_BACKGROUND_RUNNING`
      return
    }

    // 2) 初始化 AVPlayer（首次）并播放
    if (!this.avPlayer) {
      this.avPlayer = await media.createAVPlayer()
      // 本地 rawfile 音频：用资源文件描述符（fd）喂给 AVPlayer，免去网络权限/跨域
      // 相对路径即 rawfile 根目录下的文件名；正式项目播放结束后应 closeRawFileDescriptor 释放
      const rawFd = context.resourceManager.getRawFdSync('audioplayTest.mp3')
      this.avPlayer.fdSrc = { fd: rawFd.fd, offset: rawFd.offset, length: rawFd.length }
      this.avPlayer.on('stateChange', (state: string, reason: number) => {
        if (state === 'initialized') {
          this.avPlayer?.prepare()
        } else if (state === 'prepared') {
          this.avPlayer?.play()
        }
      })
      this.avPlayer.on('error', (err: BusinessError) => {
        this.log = `播放出错(${err.code}): ${err.message}`
      })
      // 音频焦点 / 打断：来电、其他 App 抢焦点时系统会下发 hint
      this.avPlayer.on('audioInterrupt', (info: audio.InterruptEvent) => this.handleAudioInterrupt(info))
    } else {
      this.avPlayer.play()
    }

    // 3) 创建并激活媒体会话（接入锁屏/控制中心控制）
    await this.setupAVSession(context)

    this.playing = true
    this.sessionActive = true
    this.updateSessionState(avSession.PlaybackState.PLAYBACK_STATE_PLAY)
    this.log = '已启动后台音频 + 媒体会话。切后台/锁屏后仍可播放，锁屏与控制中心能控制播放/暂停。'
  }

  // 创建并激活媒体会话，注册锁屏下发的控制命令
  private async setupAVSession(context: common.UIAbilityContext): Promise<void> {
    if (this.avSession) {
      return
    }
    try {
      const session: avSession.AVSession = await avSession.createAVSession(context, 'Ch35Audio', 'audio')
      this.avSession = session
      // 曲目元数据（锁屏/控制中心展示）
      const metadata: avSession.AVMetadata = {
        assetId: 'ch35-audio-001',
        title: '示例音频（后台播放）',
        artist: 'cc',
        album: '跟着cc一起学鸿蒙开发'
      }
      await session.setAVMetadata(metadata)
      await session.activate()
      // 监听锁屏/控制中心下发的控制命令：play / pause / stop
      session.on('play', () => this.resumePlayback())
      session.on('pause', () => this.pausePlayback())
      session.on('stop', () => this.stopPlayback())
    } catch (err) {
      const e: BusinessError = err as BusinessError
      this.log += `\n媒体会话创建失败(${e.code}): ${e.message}（不影响后台播放，仅缺锁屏控制）`
    }
  }

  // 音频焦点 / 打断处理：来电、其他 App 抢焦点时系统下发 hint
  private handleAudioInterrupt(info: audio.InterruptEvent): void {
    if (info.eventType === audio.InterruptType.INTERRUPT_TYPE_BEGIN) {
      switch (info.hintType) {
        case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
          this.playingBeforeInterrupt = this.playing
          this.pausePlayback()
          this.log = '音频被打断（暂停）：来电或其他 App 抢焦点，已暂停。'
          break
        case audio.InterruptHint.INTERRUPT_HINT_STOP:
          this.playingBeforeInterrupt = this.playing
          this.stopPlayback()
          this.log = '音频被打断（停止）：焦点被回收，已停止播放。'
          break
        case audio.InterruptHint.INTERRUPT_HINT_DUCK:
          // 共享焦点（如导航播报）：降音量但不暂停
          this.avPlayer?.setVolume(0.2)
          this.log = '音频被打断（DUCK）：共享焦点，已降音量。'
          break
        default:
          break
      }
    } else if (info.eventType === audio.InterruptType.INTERRUPT_TYPE_END) {
      switch (info.hintType) {
        case audio.InterruptHint.INTERRUPT_HINT_RESUME:
          if (this.playingBeforeInterrupt) {
            this.resumePlayback()
            this.log = '焦点归还：已恢复播放。'
          }
          break
        case audio.InterruptHint.INTERRUPT_HINT_UNDUCK:
          this.avPlayer?.setVolume(1.0)
          this.log = '焦点归还：已恢复音量。'
          break
        default:
          break
      }
    }
  }

  private pausePlayback(): void {
    this.avPlayer?.pause()
    this.playing = false
    this.updateSessionState(avSession.PlaybackState.PLAYBACK_STATE_PAUSE)
    this.log = '已暂停播放。'
  }

  private resumePlayback(): void {
    this.avPlayer?.play()
    this.playing = true
    this.updateSessionState(avSession.PlaybackState.PLAYBACK_STATE_PLAY)
    this.log = '已恢复播放。'
  }

  async stopPlayback(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    this.avPlayer?.pause()
    this.playing = false
    this.sessionActive = false
    this.updateSessionState(avSession.PlaybackState.PLAYBACK_STATE_STOP)
    // 媒体会话用毕即销毁，释放系统资源
    this.avSession?.destroy().catch(() => {})
    this.avSession = undefined
    if (this.taskStarted) {
      await backgroundTaskManager.stopBackgroundRunning(context)
      this.taskStarted = false
    }
    this.log = '已停止播放并停止长时任务，常驻通知与锁屏控制消失。'
  }

  // 页面销毁时释放播放器与媒体会话，并兜底停止长时任务，避免资源泄漏
  aboutToDisappear(): void {
    this.avPlayer?.release()
    this.avPlayer = undefined
    this.avSession?.destroy().catch(() => {})
    this.avSession = undefined
    if (this.taskStarted) {
      const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
      backgroundTaskManager.stopBackgroundRunning(context).catch(() => {})
      this.taskStarted = false
    }
  }

  build() {
    Column({ space: 14 }) {
      Text('后台音频播放（长时任务 · AUDIO_PLAYBACK）')
        .fontSize(20).fontWeight(FontWeight.Bold).margin({ top: 16 })

      Text('进阶：AVSession 锁屏控制 + 音频焦点/打断管理')
        .fontSize(13).fontColor('#666').width('90%')

      Button(this.playing ? '停止播放' : '开始后台播放')
        .width('80%')
        .backgroundColor(this.playing ? '#C62828' : '#2E7D32')
        .onClick(() => this.playing ? this.stopPlayback() : this.startPlayback())

      if (this.sessionActive) {
        Text('媒体会话已激活：锁屏/控制中心可播放 · 暂停 · 停止')
          .fontSize(13).fontColor('#2E7D32').width('90%')
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
