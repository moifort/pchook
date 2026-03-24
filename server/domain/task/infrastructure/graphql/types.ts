import { builder } from '~/domain/shared/graphql/builder'
import type { TaskState } from '~/domain/task/types'

export const TaskType = builder.objectRef<TaskState>('Task').implement({
  description: 'A background task with progress tracking',
  fields: (t) => ({
    id: t.field({
      type: 'TaskId',
      description: 'Unique task identifier',
      resolve: ({ id }) => id,
    }),
    phase: t.exposeString('phase', {
      description: 'Current phase (idle, running, paused, cancelled, completed, failed)',
    }),
    current: t.exposeInt('current', { description: 'Number of items processed' }),
    total: t.exposeInt('total', { description: 'Total number of items' }),
    message: t.exposeString('message', { description: 'Progress message' }),
    startedAt: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Start date',
      resolve: ({ startedAt }) => startedAt ?? null,
    }),
    completedAt: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Completion date',
      resolve: ({ completedAt }) => completedAt ?? null,
    }),
  }),
})
