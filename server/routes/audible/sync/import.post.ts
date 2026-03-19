import { AudibleUseCase } from '~/domain/audible/use-case'

export default defineEventHandler(async () => {
  const result = await AudibleUseCase.importAll()
  if (result === 'no-data') {
    throw createError({
      statusCode: 422,
      statusMessage: 'No Audible data to import. Run fetch first.',
    })
  }
  return { status: 200, data: result } as const
})
