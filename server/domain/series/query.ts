import { sortBy } from 'lodash-es'
import { BookQuery } from '~/domain/book/query'
import type { BookId } from '~/domain/book/types'
import * as repository from '~/domain/series/repository'
import type { SeriesId } from '~/domain/series/types'
import { createLogger } from '~/system/logger'

const log = createLogger('series-query')

export namespace SeriesQuery {
  export const findAll = () => repository.findAllSeries()

  export const getById = async (id: SeriesId) => {
    const series = await repository.findSeriesBy(id)
    if (!series) return 'not-found' as const
    const entries = await repository.findSeriesBooksBySeriesId(id)
    const books = await Promise.all(
      entries.map(async (entry) => {
        const book = await BookQuery.getById(entry.bookId)
        if (book === 'not-found') {
          log.warn('Orphaned SeriesBook entry', { seriesId: id, bookId: entry.bookId })
          return undefined
        }
        return { ...book, label: entry.label, position: entry.position }
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
    return { ...series, label: entry.label, position: entry.position }
  }
}
