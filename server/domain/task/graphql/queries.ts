import { builder } from '~/domain/shared/graphql/builder'
import { TaskId } from '~/domain/task/primitives'
import { TaskQuery } from '~/domain/task/query'
import { TaskType } from './types'

builder.queryField('task', (t) =>
  t.field({
    type: TaskType,
    nullable: true,
    description: 'Get a task by its identifier',
    args: {
      id: t.arg.id({ required: true, description: 'Task identifier' }),
    },
    resolve: async (_, { id }) => {
      const taskId = TaskId(id)
      const result = await TaskQuery.getById(taskId)
      if (result === 'not-found') return null
      return result
    },
  }),
)
