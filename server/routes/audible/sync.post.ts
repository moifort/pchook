import { AudibleUseCase } from '~/domain/audible/use-case'

export default defineEventHandler(async () => {
  const result = await AudibleUseCase.syncAll()
  if (result === 'no-credentials') {
    throw createError({ statusCode: 422, statusMessage: 'Audible credentials not configured' })
  }
  return { status: 200, data: result } as const
})
