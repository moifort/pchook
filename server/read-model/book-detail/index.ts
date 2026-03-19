import { BookQuery } from '~/domain/book/query'
import type { BookId } from '~/domain/book/types'
import { ReviewQuery } from '~/domain/review/query'
import { SeriesQuery } from '~/domain/series/query'
import type { BookDetailView, SeriesInfo } from './types'

export namespace BookDetailReadModel {
  export const byId = async (id: BookId) => {
    const book = await BookQuery.getById(id)
    if (book === 'not-found') return 'not-found' as const

    const [coverImageBase64, seriesInfo, reviewResult] = await Promise.all([
      BookQuery.getImageById(id),
      SeriesQuery.getByBookId(id),
      ReviewQuery.getByBookId(id),
    ])

    let series: SeriesInfo | undefined
    if (seriesInfo) {
      const fullSeries = await SeriesQuery.getById(seriesInfo.id)
      if (fullSeries !== 'not-found') {
        const bookLanguage = book.language ? String(book.language) : undefined
        series = {
          name: String(fullSeries.name),
          position: seriesInfo.position,
          books: fullSeries.books
            .filter(({ language }) => {
              const lang = language ? String(language) : undefined
              return lang === bookLanguage
            })
            .map(({ id, title, position }) => ({
              id,
              title: String(title),
              position,
            })),
        }
      }
    }

    const review = reviewResult === 'not-found' ? undefined : reviewResult

    const sanitizedBook = {
      ...book,
      publicRatings: book.publicRatings.map(({ source, score, maxScore, voterCount }) => ({
        source,
        score,
        maxScore,
        voterCount: Math.round(voterCount),
      })),
    }

    return {
      book: sanitizedBook,
      coverImageBase64: coverImageBase64 ?? undefined,
      series,
      review,
    } satisfies BookDetailView
  }
}
