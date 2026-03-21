import { createLogger } from '~/system/logger'
import { createTypedStorage } from '~/system/storage'

const log = createLogger('task-runner')

export type TaskPhase = 'idle' | 'running' | 'paused' | 'cancelled' | 'completed' | 'failed'

export type TaskState = {
  phase: TaskPhase
  current: number
  total: number
  message: string
  startedAt: Date | null
  completedAt: Date | null
}

export type TaskDefinition<T> = {
  items: () => Promise<T[]>
  execute: (item: T) => Promise<void>
  label: (item: T) => string
}

const IDLE_STATE: TaskState = {
  phase: 'idle',
  current: 0,
  total: 0,
  message: '',
  startedAt: null,
  completedAt: null,
}

export const createTaskRunner = (storageKey: string) => {
  const storage = createTypedStorage<TaskState>(`task:${storageKey}`)
  let cancelRequested = false
  let pauseResolve: (() => void) | null = null
  let pausePromise: Promise<void> | null = null
  let running = false

  const getState = async () => (await storage.getItem('state')) ?? IDLE_STATE

  const setState = async (state: TaskState) => {
    await storage.setItem('state', state)
  }

  const selfHeal = async () => {
    const state = await getState()
    if ((state.phase === 'running' || state.phase === 'paused') && !running) {
      log.warn('Task was interrupted, marking as failed', { storageKey })
      await setState({ ...state, phase: 'failed', completedAt: new Date() })
    }
  }

  const start = async <T>(definition: TaskDefinition<T>) => {
    const currentState = await getState()
    if (currentState.phase === 'running' || currentState.phase === 'paused') {
      return 'already-running' as const
    }

    cancelRequested = false
    pausePromise = null
    pauseResolve = null
    running = true

    const items = await definition.items()
    const total = items.length

    log.info('Task starting', { storageKey, total })
    await setState({
      phase: 'running',
      current: 0,
      total,
      message: '',
      startedAt: new Date(),
      completedAt: null,
    })

    try {
      for (const [index, item] of items.entries()) {
        if (cancelRequested) {
          log.info('Task cancelled', { storageKey, current: index })
          await setState({ ...(await getState()), phase: 'cancelled', completedAt: new Date() })
          return 'cancelled' as const
        }

        if (pausePromise) {
          await setState({ ...(await getState()), phase: 'paused' })
          log.info('Task paused', { storageKey, current: index })
          await pausePromise
          log.info('Task resumed', { storageKey })
        }

        const message = definition.label(item)
        await setState({
          phase: 'running',
          current: index + 1,
          total,
          message,
          startedAt: (await getState()).startedAt,
          completedAt: null,
        })

        await definition.execute(item)
      }

      log.info('Task completed', { storageKey, total })
      await setState({
        phase: 'completed',
        current: total,
        total,
        message: '',
        startedAt: (await getState()).startedAt,
        completedAt: new Date(),
      })
      return 'completed' as const
    } catch (error) {
      log.error('Task failed', { storageKey, error: String(error) })
      await setState({
        ...(await getState()),
        phase: 'failed',
        message: String(error),
        completedAt: new Date(),
      })
      return 'failed' as const
    } finally {
      running = false
      cancelRequested = false
      pausePromise = null
      pauseResolve = null
    }
  }

  const pause = () => {
    if (!running) return
    pausePromise = new Promise((resolve) => {
      pauseResolve = resolve
    })
  }

  const resume = () => {
    pauseResolve?.()
    pausePromise = null
    pauseResolve = null
  }

  const cancel = () => {
    cancelRequested = true
    if (pausePromise) {
      pauseResolve?.()
      pausePromise = null
      pauseResolve = null
    }
  }

  const reset = async () => {
    cancel()
    await setState(IDLE_STATE)
  }

  return { getState, start, pause, resume, cancel, reset, selfHeal }
}
