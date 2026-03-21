import { AudibleCommand } from '~/domain/audible/command'
import { AudibleQuery } from '~/domain/audible/query'

export default defineEventHandler(() => {
  const progress = AudibleQuery.getSyncProgress()
  if (progress.phase === 'idle') {
    throw createError({ statusCode: 409, statusMessage: 'No sync in progress' })
  }

  AudibleCommand.requestCancel()
  if (AudibleQuery.isPaused()) {
    AudibleCommand.requestResume()
  }

  return { status: 200, data: { cancelled: true } } as const
})
