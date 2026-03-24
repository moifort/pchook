import { builder } from '~/domain/shared/graphql/builder'
import type { TaskState } from '~/domain/task/types'

export const TaskType = builder.objectRef<TaskState>('Task').implement({
  description: 'A background task with progress tracking',
  fields: (t) => ({
    id: t.id({
      description: 'Unique task identifier',
      resolve: ({ id }) => String(id),
    }),
    phase: t.exposeString('phase', {
      description: 'Current phase (idle, running, paused, cancelled, completed, failed)',
    }),
    current: t.exposeInt('current', { description: 'Number of items processed' }),
    total: t.exposeInt('total', { description: 'Total number of items' }),
    message: t.exposeString('message', { description: 'Progress message' }),
    startedAt: t.string({
      nullable: true,
      description: 'Start date (ISO 8601)',
      resolve: ({ startedAt }) => startedAt?.toISOString() ?? null,
    }),
    completedAt: t.string({
      nullable: true,
      description: 'Completion date (ISO 8601)',
      resolve: ({ completedAt }) => completedAt?.toISOString() ?? null,
    }),
  }),
})
