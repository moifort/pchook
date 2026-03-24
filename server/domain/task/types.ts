import type { Brand } from 'ts-brand'

export type TaskId = Brand<string, 'TaskId'>
export type TaskPhase = 'idle' | 'running' | 'paused' | 'cancelled' | 'completed' | 'failed'

export type TaskState = {
  id: TaskId
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
