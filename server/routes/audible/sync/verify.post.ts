import { AudibleUseCase } from '~/domain/audible/use-case'

export default defineEventHandler(async () => {
  const result = await AudibleUseCase.verify()
  if (result === 'no-credentials') {
    throw createError({ statusCode: 422, statusMessage: 'Audible credentials not configured' })
  }
  if (result === 'invalid-credentials') {
    throw createError({ statusCode: 401, statusMessage: 'Audible credentials are invalid' })
  }
  return { status: 200, data: { verified: true } } as const
})
