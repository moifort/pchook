import { importRunner } from '~/domain/audible/use-case'

export default defineEventHandler(async () => {
  const state = await importRunner.getState()

  if (state.phase === 'paused') {
    importRunner.resume()
    return { status: 200, data: { paused: false } } as const
  }

  if (state.phase !== 'running') {
    throw createError({ statusCode: 409, statusMessage: 'No import in progress to pause' })
  }

  importRunner.pause()
  return { status: 200, data: { paused: true } } as const
})
