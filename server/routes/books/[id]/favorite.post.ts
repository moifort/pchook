import { FAVORITE_RATING } from '~/domain/book/business-rules'
import { BookCommand } from '~/domain/book/command'
import { BookId, Note } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import { ReviewCommand } from '~/domain/review/command'
import type { Review } from '~/domain/review/types'

export default defineEventHandler(async (event) => {
  const id = BookId(getRouterParam(event, 'id'))

  const book = await BookQuery.getById(id)
  if (book === 'not-found') {
    throw createError({ statusCode: 404, statusMessage: 'Book not found' })
  }

  const review: Review = {
    bookId: id,
    rating: Note(FAVORITE_RATING),
    readDate: new Date(),
    createdAt: new Date(),
  }

  await ReviewCommand.create(review)
  await BookCommand.update(id, { status: 'read', readDate: new Date() })

  return { status: 201, data: review } as const
})
