import { GraphQLError } from 'graphql'
import { builder } from '~/domain/shared/graphql/builder'
import { TaskQuery } from '~/domain/task/query'
import { TaskRunner } from '~/domain/task/runner'
import { TaskType } from './types'

const taskNotFound = () => new GraphQLError('Task not found', { extensions: { code: 'NOT_FOUND' } })

builder.mutationField('pauseTask', (t) =>
  t.field({
    type: TaskType,
    description: 'Pause a running task',
    args: {
      id: t.arg({ type: 'TaskId', required: true, description: 'Task identifier' }),
    },
    resolve: async (_, { id }) => {
      const state = await TaskQuery.getById(id)
      if (state === 'not-found') throw taskNotFound()

      if (state.phase !== 'running') {
        throw new GraphQLError('Task is not running', { extensions: { code: 'CONFLICT' } })
      }

      TaskRunner.pause(id)
      return state
    },
  }),
)

builder.mutationField('resumeTask', (t) =>
  t.field({
    type: TaskType,
    description: 'Resume a paused task',
    args: {
      id: t.arg({ type: 'TaskId', required: true, description: 'Task identifier' }),
    },
    resolve: async (_, { id }) => {
      const state = await TaskQuery.getById(id)
      if (state === 'not-found') throw taskNotFound()

      if (state.phase !== 'paused') {
        throw new GraphQLError('Task is not paused', { extensions: { code: 'CONFLICT' } })
      }

      TaskRunner.resume(id)
      return state
    },
  }),
)

builder.mutationField('cancelTask', (t) =>
  t.field({
    type: TaskType,
    description: 'Cancel a running or paused task',
    args: {
      id: t.arg({ type: 'TaskId', required: true, description: 'Task identifier' }),
    },
    resolve: async (_, { id }) => {
      const state = await TaskQuery.getById(id)
      if (state === 'not-found') throw taskNotFound()

      if (state.phase !== 'running' && state.phase !== 'paused') {
        throw new GraphQLError('No task in progress to cancel', {
          extensions: { code: 'CONFLICT' },
        })
      }

      TaskRunner.cancel(id)
      return state
    },
  }),
)
