import { AudibleQuery } from '~/domain/audible/query'
import { AudibleUseCase } from '~/domain/audible/use-case'
import { createLogger } from '~/system/logger'

const log = createLogger('audible-fetch')

export default defineEventHandler(async () => {
  const credentials = await AudibleQuery.getCredentials()
  if (!credentials) {
    throw createError({ statusCode: 422, statusMessage: 'Audible credentials not configured' })
  }

  const progress = AudibleQuery.getSyncProgress()
  if (progress.phase !== 'idle') {
    throw createError({ statusCode: 409, statusMessage: 'Sync already in progress' })
  }

  AudibleUseCase.fetchAndStore().catch((error) => {
    log.error('Background fetch failed', { error: String(error) })
  })

  return { status: 202, data: { started: true } } as const
})
