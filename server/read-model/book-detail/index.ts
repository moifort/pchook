import { BookQuery } from '~/domain/book/query'
import type { BookId } from '~/domain/book/types'
import { ReviewQuery } from '~/domain/review/query'
import { SeriesQuery } from '~/domain/series/query'
import { SuggestionQuery } from '~/domain/suggestion/query'
import type { BookDetailView, SeriesInfo } from './types'

export namespace BookDetailReadModel {
  export const byId = async (id: BookId) => {
    const book = await BookQuery.getById(id)
    if (book === 'not-found') return 'not-found' as const

    const [coverImageBase64, seriesInfo, reviewResult, suggestions] = await Promise.all([
      BookQuery.getImageById(id),
      SeriesQuery.getByBookId(id),
      ReviewQuery.getByBookId(id),
      SuggestionQuery.getBySourceBookId(id),
    ])

    let series: SeriesInfo | undefined
    if (seriesInfo) {
      const fullSeries = await SeriesQuery.getById(seriesInfo.id)
      if (fullSeries !== 'not-found') {
        series = {
          name: String(fullSeries.name),
          position: seriesInfo.position,
          books: fullSeries.books.map(({ id, title, position }) => ({
            id,
            title: String(title),
            position,
          })),
        }
      }
    }

    const review = reviewResult === 'not-found' ? undefined : reviewResult

    return {
      book,
      coverImageBase64,
      series,
      review,
      suggestions,
    } satisfies BookDetailView
  }
}
