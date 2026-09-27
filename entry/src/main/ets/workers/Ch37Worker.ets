import { worker } from '@kit.ArkTS'

const parentPort = worker.workerPort

interface WorkerMsg {
  type: string
  value: number
}

// Long CPU task. We split it into chunks and post progress messages so the host
// UI can render a live progress bar — something a one-shot TaskPool task can't do.
parentPort.onmessage = (e): void => {
  const total: number = e.data as number
  let sum: number = 0
  const chunk: number = Math.max(1, Math.floor(total / 20))
  for (let i: number = 0; i < total; i++) {
    sum += Math.sqrt(i * 1.0001) * Math.sin(i * 0.0001)
    if (i % chunk === 0) {
      const progressMsg: WorkerMsg = { type: 'progress', value: Math.floor((i / total) * 100) }
      parentPort.postMessage(progressMsg)
    }
  }
  const doneMsg: WorkerMsg = { type: 'done', value: sum }
  parentPort.postMessage(doneMsg)
}
