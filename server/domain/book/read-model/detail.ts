import { BookQuery } from '~/domain/book/query'
import type { BookId } from '~/domain/book/types'
import { ReviewQuery } from '~/domain/review/query'
import { booksInLanguage } from '~/domain/series/business-rules'
import { SeriesQuery } from '~/domain/series/query'
import type { BookDetailView, SeriesInfo } from './types'

export namespace BookDetailReadModel {
  export const byId = async (id: BookId) => {
    const book = await BookQuery.getById(id)
    if (book === 'not-found') return 'not-found' as const

    const [seriesInfo, reviewResult] = await Promise.all([
      SeriesQuery.getByBookId(id),
      ReviewQuery.getByBookId(id),
    ])

    let series: SeriesInfo | undefined
    if (seriesInfo) {
      const fullSeries = await SeriesQuery.getById(seriesInfo.id)
      if (fullSeries !== 'not-found') {
        series = {
          name: fullSeries.name,
          label: seriesInfo.label,
          position: seriesInfo.position,
          books: booksInLanguage(fullSeries.books, book.language).map(
            ({ id, title, label, position }) => ({
              id,
              title,
              label,
              position,
            }),
          ),
        }
      }
    }

    const review = reviewResult === 'not-found' ? undefined : reviewResult

    return {
      book,
      series,
      review,
    } satisfies BookDetailView
  }
}
