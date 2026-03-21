import { AudibleCommand } from '~/domain/audible/command'
import { AudibleQuery } from '~/domain/audible/query'

export default defineEventHandler(() => {
  const progress = AudibleQuery.getSyncProgress()

  if (progress.phase === 'paused') {
    AudibleCommand.requestResume()
    return { status: 200, data: { paused: false } } as const
  }

  if (progress.phase !== 'downloading' && progress.phase !== 'importing') {
    throw createError({ statusCode: 409, statusMessage: 'No sync in progress to pause' })
  }

  AudibleCommand.requestPause()
  return { status: 200, data: { paused: true } } as const
})
