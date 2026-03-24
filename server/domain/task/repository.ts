import type { TaskId, TaskState } from '~/domain/task/types'
import { createTypedStorage } from '~/system/storage'

const storage = () => createTypedStorage<TaskState>('tasks')

export const findBy = (id: TaskId) => storage().getItem(id)

export const save = async (state: TaskState) => {
  await storage().setItem(state.id, state)
  return state
}

export const remove = async (id: TaskId) => {
  await storage().removeItem(id)
}
