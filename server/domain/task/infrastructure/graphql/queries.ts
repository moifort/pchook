import { builder } from '~/domain/shared/graphql/builder'
import { TaskQuery } from '~/domain/task/query'
import { TaskType } from './types'

builder.queryField('task', (t) =>
  t.field({
    type: TaskType,
    nullable: true,
    description: 'Get a task by its identifier',
    args: {
      id: t.arg({ type: 'TaskId', required: true, description: 'Task identifier' }),
    },
    resolve: async (_, { id }) => {
      const result = await TaskQuery.getById(id)
      if (result === 'not-found') return null
      return result
    },
  }),
)
