import { importRunner } from '~/domain/audible/use-case'

export default defineEventHandler(async () => {
  const state = await importRunner.getState()
  if (state.phase !== 'running' && state.phase !== 'paused') {
    throw createError({ statusCode: 409, statusMessage: 'No import in progress to cancel' })
  }

  importRunner.cancel()
  return { status: 200, data: { cancelled: true } } as const
})
