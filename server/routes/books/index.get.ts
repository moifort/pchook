import { BookSort, BookStatus, Genre, SortOrder } from '~/domain/book/primitives'
import { BookListReadModel } from '~/domain/book/read-model/list'

export default defineEventHandler(async (event) => {
  const query = getQuery(event)

  const filters = {
    genre: query.genre ? Genre(query.genre) : undefined,
    status: query.status ? BookStatus(query.status) : undefined,
    sort: query.sort ? BookSort(query.sort) : undefined,
    order: query.order ? SortOrder(query.order) : undefined,
  }

  const books = await BookListReadModel.all(filters)

  return { status: 200, data: books } as const
})
