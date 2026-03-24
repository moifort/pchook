import { make } from 'ts-brand'
import { z } from 'zod'
import type { TaskId as TaskIdType } from '~/domain/task/types'

export const TaskId = (value: unknown) => {
  const v = z.string().uuid().parse(value)
  return make<TaskIdType>()(v)
}

export const randomTaskId = () => TaskId(crypto.randomUUID())
