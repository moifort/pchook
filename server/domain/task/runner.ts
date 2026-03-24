import { TaskCommand } from '~/domain/task/command'
import { TaskQuery } from '~/domain/task/query'
import type { TaskDefinition, TaskId, TaskState } from '~/domain/task/types'
import { createLogger } from '~/system/logger'

const log = createLogger('task-runner')

type RunningTask = {
  cancelRequested: boolean
  pauseResolve: (() => void) | null
  pausePromise: Promise<void> | null
}

const runningTasks = new Map<string, RunningTask>()

const isActive = (id: TaskId) => runningTasks.has(id)

const ensureState = async (id: TaskId) => {
  const state = await TaskQuery.getById(id)
  if (state === 'not-found') {
    return await TaskCommand.create(id)
  }
  return state
}

const updateState = async (id: TaskId, updates: Partial<TaskState>) => {
  const result = await TaskCommand.updateState(id, updates)
  if (result === 'not-found') throw new Error(`Task ${id} not found during update`)
  return result
}

export namespace TaskRunner {
  export const start = async <T>(id: TaskId, definition: TaskDefinition<T>) => {
    const currentState = await ensureState(id)
    if (currentState.phase === 'running' || currentState.phase === 'paused') {
      return 'already-running' as const
    }

    const control: RunningTask = {
      cancelRequested: false,
      pauseResolve: null,
      pausePromise: null,
    }
    runningTasks.set(id, control)

    const items = await definition.items()
    const total = items.length

    log.info('Task starting', { id, total })
    await updateState(id, {
      phase: 'running',
      current: 0,
      total,
      message: '',
      startedAt: new Date(),
      completedAt: null,
    })

    try {
      for (const [index, item] of items.entries()) {
        if (control.cancelRequested) {
          log.info('Task cancelled', { id, current: index })
          await updateState(id, { phase: 'cancelled', completedAt: new Date() })
          return 'cancelled' as const
        }

        if (control.pausePromise) {
          await updateState(id, { phase: 'paused' })
          log.info('Task paused', { id, current: index })
          await control.pausePromise
          log.info('Task resumed', { id })
        }

        const message = definition.label(item)
        const existing = await TaskQuery.getById(id)
        const startedAt = existing !== 'not-found' ? existing.startedAt : null
        await updateState(id, {
          phase: 'running',
          current: index + 1,
          total,
          message,
          startedAt,
          completedAt: null,
        })

        await definition.execute(item)
      }

      const existing = await TaskQuery.getById(id)
      const startedAt = existing !== 'not-found' ? existing.startedAt : null
      log.info('Task completed', { id, total })
      await updateState(id, {
        phase: 'completed',
        current: total,
        total,
        message: '',
        startedAt,
        completedAt: new Date(),
      })
      return 'completed' as const
    } catch (error) {
      log.error('Task failed', { id, error: String(error) })
      await updateState(id, {
        phase: 'failed',
        message: String(error),
        completedAt: new Date(),
      })
      return 'failed' as const
    } finally {
      runningTasks.delete(id)
    }
  }

  export const pause = (id: TaskId) => {
    const control = runningTasks.get(id)
    if (!control) return
    control.pausePromise = new Promise((resolve) => {
      control.pauseResolve = resolve
    })
  }

  export const resume = (id: TaskId) => {
    const control = runningTasks.get(id)
    if (!control) return
    control.pauseResolve?.()
    control.pausePromise = null
    control.pauseResolve = null
  }

  export const cancel = (id: TaskId) => {
    const control = runningTasks.get(id)
    if (!control) return
    control.cancelRequested = true
    if (control.pausePromise) {
      control.pauseResolve?.()
      control.pausePromise = null
      control.pauseResolve = null
    }
  }

  export const reset = async (id: TaskId) => {
    cancel(id)
    await TaskCommand.create(id)
  }

  export const selfHeal = async (id: TaskId) => {
    const state = await TaskQuery.getById(id)
    if (state === 'not-found') return
    if ((state.phase === 'running' || state.phase === 'paused') && !isActive(id)) {
      log.warn('Task was interrupted, marking as failed', { id })
      await updateState(id, { phase: 'failed', completedAt: new Date() })
    }
  }
}
