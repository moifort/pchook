import { sortBy, sumBy } from 'lodash-es'
import { FAVORITE_RATING, isFavorite } from '~/domain/book/business-rules'
import { BookQuery } from '~/domain/book/query'
import { ReviewQuery } from '~/domain/review/query'
import { SeriesQuery } from '~/domain/series/query'
import type {
  DashboardView,
  FavoriteBook,
  FavoriteSeries,
  RecentBook,
  RecommendedBook,
} from './types'

const LIST_LIMIT = 5

export namespace DashboardReadModel {
  export const get = async () => {
    const [books, reviews, allSeries] = await Promise.all([
      BookQuery.findAll(),
      ReviewQuery.getAll(),
      SeriesQuery.findAll(),
    ])

    const reviewByBookId = new Map(reviews.map((review) => [review.bookId, review]))

    const total = books.length
    const read = books.filter(({ status }) => status === 'read').length
    const toRead = total - read
    const totalAudioMinutes = sumBy(
      books.filter(({ format }) => format === 'audiobook'),
      ({ durationMinutes }) => durationMinutes ?? 0,
    )

    const favorites = books
      .filter(({ id }) => {
        const review = reviewByBookId.get(id)
        return review && isFavorite(review.rating)
      })
      .slice(0, LIST_LIMIT)
      .map(({ id, title, authors, genre, language }) => ({
        id,
        title,
        authors,
        genre,
        language,
      })) satisfies FavoriteBook[]

    const recentBooks = sortBy(books, ({ createdAt }) => -createdAt.getTime())
      .slice(0, LIST_LIMIT)
      .map(({ id, title, authors, genre, language }) => ({
        id,
        title,
        authors,
        genre,
        language,
      })) satisfies RecentBook[]

    const recommendedBooks = books
      .filter(({ recommendedBy }) => recommendedBy !== undefined)
      .slice(0, LIST_LIMIT)
      .map(({ id, title, authors, genre, language, recommendedBy }) => ({
        id,
        title,
        authors,
        genre,
        language,
        recommendedBy: recommendedBy!,
      })) satisfies RecommendedBook[]

    const favoriteSeries = allSeries
      .filter(({ rating }) => rating === FAVORITE_RATING)
      .map((series) => ({
        id: series.id,
        name: series.name,
      }))

    const resolvedFavoriteSeries = await Promise.all(
      favoriteSeries.map(async ({ id, name }): Promise<FavoriteSeries | undefined> => {
        const detail = await SeriesQuery.getById(id)
        if (detail === 'not-found') return undefined
        const sortedBooks = sortBy(detail.books, ({ position }) => position)
        const firstBook = sortedBooks[0]
        const firstBookData = firstBook
          ? books.find(({ id: bookId }) => bookId === firstBook.id)
          : undefined
        return {
          id,
          name,
          volumeCount: detail.books.length,
          authors: firstBookData?.authors ?? [],
          language: firstBookData?.language,
          firstBookId: firstBook?.id,
        } satisfies FavoriteSeries
      }),
    )

    const resolvedSeries: FavoriteSeries[] = resolvedFavoriteSeries.filter(
      (s): s is FavoriteSeries => s !== undefined,
    )

    return {
      bookCount: { total, toRead, read, totalAudioMinutes },
      favorites,
      recentBooks,
      recommendedBooks,
      favoriteSeries: resolvedSeries,
    } satisfies DashboardView
  }
}
