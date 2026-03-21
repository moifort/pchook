import { importRunner, importTaskDefinition } from '~/domain/audible/use-case'
import { createLogger } from '~/system/logger'

const log = createLogger('audible-import-start')

export default defineEventHandler(async () => {
  const state = await importRunner.getState()
  if (state.phase === 'running' || state.phase === 'paused') {
    throw createError({ statusCode: 409, statusMessage: 'Import already in progress' })
  }

  importRunner.start(importTaskDefinition).catch((error) => {
    log.error('Background import failed', { error: String(error) })
  })

  return { status: 202, data: { started: true } } as const
})
