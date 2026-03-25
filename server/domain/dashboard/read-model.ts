import { sortBy } from 'lodash-es'
import { isFavorite } from '~/domain/book/business-rules'
import { BookQuery } from '~/domain/book/query'
import { ReviewQuery } from '~/domain/review/query'
import type { DashboardView, FavoriteBook, RecentAward, RecentBook } from './types'

const RECENT_BOOKS_LIMIT = 5

export namespace DashboardReadModel {
  export const get = async () => {
    const [books, reviews] = await Promise.all([BookQuery.findAll(), ReviewQuery.getAll()])

    const reviewByBookId = new Map(reviews.map((review) => [review.bookId, review]))

    const total = books.length
    const read = books.filter(({ status }) => status === 'read').length
    const toRead = total - read

    const favorites = books.reduce<FavoriteBook[]>(
      (acc, { id, title, authors, genre, readDate, estimatedPrice }) => {
        const review = reviewByBookId.get(id)
        if (review && isFavorite(review.rating)) {
          acc.push({
            id,
            title,
            authors,
            genre,
            rating: review.rating,
            readDate,
            estimatedPrice,
          })
        }
        return acc
      },
      [],
    )

    const recentBooks = sortBy(books, ({ createdAt }) => -createdAt.getTime())
      .slice(0, RECENT_BOOKS_LIMIT)
      .map(({ id, title, authors, genre, createdAt }) => ({
        id,
        title,
        authors,
        genre,
        createdAt,
      })) satisfies RecentBook[]

    const currentYear = new Date().getFullYear()
    const recentAwards = books.flatMap(({ title, authors, awards }) =>
      awards
        .filter(
          (award): award is { name: string; year: number } =>
            award.year !== undefined && award.year >= currentYear - 1,
        )
        .map(({ name, year }) => ({
          bookTitle: title,
          authors,
          awardName: name,
          awardYear: year,
        })),
    ) satisfies RecentAward[]

    return {
      bookCount: { total, toRead, read },
      favorites,
      recentBooks,
      recentAwards,
    } satisfies DashboardView
  }
}
