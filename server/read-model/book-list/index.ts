import { sortBy } from 'lodash-es'
import { awardsCount, popularityScore } from '~/domain/book/business-rules'
import { BookQuery } from '~/domain/book/query'
import type { BookSort, BookStatus, Genre, SortOrder } from '~/domain/book/types'
import { ReviewQuery } from '~/domain/review/query'
import { SeriesQuery } from '~/domain/series/query'
import type { BookListItem } from './types'

type Filters = {
  genre?: Genre
  status?: BookStatus
  sort?: BookSort
  order?: SortOrder
}

export namespace BookListReadModel {
  export const all = async (filters: Filters) => {
    const [books, reviews, seriesInfos] = await Promise.all([
      BookQuery.findAll(),
      ReviewQuery.getAll(),
      Promise.all(
        (await BookQuery.findAll()).map(async ({ id }) => {
          const info = await SeriesQuery.getByBookId(id)
          return { bookId: id, seriesName: info ? String(info.name) : undefined }
        }),
      ),
    ])

    const reviewByBookId = new Map(reviews.map((review) => [review.bookId, review]))
    const seriesByBookId = new Map(
      seriesInfos.map(({ bookId, seriesName }) => [bookId, seriesName]),
    )

    let items = books.map(
      ({
        id,
        title,
        authors,
        genre,
        status,
        estimatedPrice,
        awards,
        publicRatings,
        createdAt,
      }) => ({
        id,
        title: String(title),
        authors,
        genre,
        status,
        estimatedPrice,
        awards,
        publicRatings,
        rating: reviewByBookId.get(id)?.rating,
        seriesName: seriesByBookId.get(id),
        createdAt,
      }),
    ) satisfies BookListItem[]

    if (filters.genre) {
      items = items.filter(({ genre }) => genre === filters.genre)
    }

    if (filters.status) {
      items = items.filter(({ status }) => status === filters.status)
    }

    const sort = filters.sort ?? 'createdAt'
    const desc = (filters.order ?? 'desc') === 'desc'

    const sorted = sortBy(items, (item) => {
      if (sort === 'title') return item.title.toLowerCase()
      if (sort === 'author') return item.authors[0] ? String(item.authors[0]).toLowerCase() : ''
      if (sort === 'publicRating') return popularityScore(item.publicRatings)
      if (sort === 'awards') return awardsCount(item.awards)
      if (sort === 'genre') return (item.genre ?? '').toLowerCase()
      return new Date(item.createdAt).getTime()
    })

    return desc ? sorted.reverse() : sorted
  }
}
