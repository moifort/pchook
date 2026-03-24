import * as repository from '~/domain/task/repository'
import type { TaskId, TaskState } from '~/domain/task/types'

const IDLE_STATE = (id: TaskId): TaskState => ({
  id,
  phase: 'idle',
  current: 0,
  total: 0,
  message: '',
  startedAt: null,
  completedAt: null,
})

export namespace TaskCommand {
  export const create = async (id: TaskId) => {
    const state = IDLE_STATE(id)
    return await repository.save(state)
  }

  export const updateState = async (id: TaskId, updates: Partial<TaskState>) => {
    const existing = await repository.findBy(id)
    if (!existing) return 'not-found' as const
    return await repository.save({ ...existing, ...updates })
  }

  export const remove = async (id: TaskId) => {
    await repository.remove(id)
  }
}
