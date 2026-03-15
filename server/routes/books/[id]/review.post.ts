import { BookCommand } from '~/domain/book/command'
import { BookId, Note } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import { ReviewCommand } from '~/domain/review/command'
import type { Review } from '~/domain/review/types'

export default defineEventHandler(async (event) => {
  const id = BookId(getRouterParam(event, 'id'))
  const body = await readBody(event)
  if (!body) throw createError({ statusCode: 400, statusMessage: 'No body provided' })

  const book = await BookQuery.getById(id)
  if (book === 'not-found') {
    throw createError({ statusCode: 404, statusMessage: 'Book not found' })
  }

  const review: Review = {
    bookId: id,
    rating: Note(body.rating),
    readDate: body.readDate ? new Date(body.readDate) : undefined,
    reviewNotes: body.reviewNotes as string | undefined,
    createdAt: new Date(),
  }

  await ReviewCommand.create(review)
  await BookCommand.update(id, {
    status: 'read',
    readDate: review.readDate ?? new Date(),
  })

  return { status: 201, data: review } as const
})
