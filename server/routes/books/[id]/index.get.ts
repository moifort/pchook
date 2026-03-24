import { BookId } from '~/domain/book/primitives'
import { BookDetailReadModel } from '~/domain/book/read-model/detail'

export default defineEventHandler(async (event) => {
  const id = BookId(getRouterParam(event, 'id'))
  const result = await BookDetailReadModel.byId(id)

  if (result === 'not-found') {
    throw createError({ statusCode: 404, statusMessage: 'Book not found' })
  }

  return { status: 200, data: result } as const
})
