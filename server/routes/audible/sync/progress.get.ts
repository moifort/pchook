import { AudibleQuery } from '~/domain/audible/query'

export default defineEventHandler(() => {
  return { status: 200, data: AudibleQuery.getSyncProgress() } as const
})
