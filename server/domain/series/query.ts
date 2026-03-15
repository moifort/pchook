import { sortBy } from 'lodash-es'
import { BookQuery } from '~/domain/book/query'
import type { BookId } from '~/domain/book/types'
import * as repository from '~/domain/series/repository'
import type { SeriesId } from '~/domain/series/types'

export namespace SeriesQuery {
  export const findAll = () => repository.findAllSeries()

  export const getById = async (id: SeriesId) => {
    const series = await repository.findSeriesBy(id)
    if (!series) return 'not-found' as const
    const entries = await repository.findSeriesBooksBySeriesId(id)
    const books = await Promise.all(
      entries.map(async (entry) => {
        const book = await BookQuery.getById(entry.bookId)
        if (book === 'not-found') return undefined
        return { ...book, position: entry.position }
      }),
    )
    return {
      ...series,
      books: sortBy(
        books.filter((b) => b !== undefined),
        'position',
      ),
    }
  }

  export const getByBookId = async (bookId: BookId) => {
    const entry = await repository.findSeriesBookByBookId(bookId)
    if (!entry) return null
    const series = await repository.findSeriesBy(entry.seriesId)
    if (!series) return null
    return { ...series, position: entry.position }
  }
}
