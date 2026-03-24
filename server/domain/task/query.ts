import * as repository from '~/domain/task/repository'
import type { TaskId } from '~/domain/task/types'

export namespace TaskQuery {
  export const getById = async (id: TaskId) => {
    const task = await repository.findBy(id)
    if (!task) return 'not-found' as const
    return task
  }
}
