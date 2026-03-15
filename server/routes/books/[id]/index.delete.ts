import { BookId } from '~/domain/book/primitives'
import { BookUseCase } from '~/domain/book/use-case'

export default defineEventHandler(async (event) => {
  const id = BookId(getRouterParam(event, 'id'))
  const result = await BookUseCase.removeCompletely(id)

  if (result === 'not-found') {
    throw createError({ statusCode: 404, statusMessage: 'Book not found' })
  }

  return { status: 200, data: null } as const
})
