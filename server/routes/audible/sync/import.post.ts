import { AudibleQuery } from '~/domain/audible/query'
import { AudibleUseCase } from '~/domain/audible/use-case'
import { createLogger } from '~/system/logger'

const log = createLogger('audible-import')

export default defineEventHandler(async () => {
  const rawItems = await AudibleQuery.getAllRawItems()
  if (rawItems.length === 0) {
    throw createError({
      statusCode: 422,
      statusMessage: 'No Audible data to import. Run fetch first.',
    })
  }

  const progress = AudibleQuery.getSyncProgress()
  if (progress.phase !== 'idle') {
    throw createError({ statusCode: 409, statusMessage: 'Sync already in progress' })
  }

  AudibleUseCase.importAll().catch((error) => {
    log.error('Background import failed', { error: String(error) })
  })

  return { status: 202, data: { started: true } } as const
})
