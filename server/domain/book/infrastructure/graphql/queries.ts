import { getRequestURL } from 'h3'
import { keyBy, sortBy } from 'lodash-es'
import { match } from 'ts-pattern'
import { awardsCount } from '~/domain/book/business-rules'
import { BookSort, BookStatus, SortOrder } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import { ReviewQuery } from '~/domain/review/query'
import { SeriesQuery } from '~/domain/series/query'
import { builder } from '~/domain/shared/graphql/builder'
import { Url } from '~/domain/shared/primitives'
import { BookSortEnum, SortOrderEnum } from './enums'
import { BooksType, BookType } from './types'

builder.objectField(BookType, 'coverImageUrl', (t) =>
  t.field({
    type: 'Url',
    nullable: true,
    description: 'Absolute URL to the cover image. Null if no cover',
    resolve: ({ coverImageId }, _, { event }) => {
      if (!coverImageId) return null
      const origin = getRequestURL(event).origin
      return Url(`${origin}/images/${coverImageId}`)
    },
  }),
)

builder.queryField('books', (t) =>
  t.field({
    type: BooksType,
    description: 'Paginated book list with filters and sorting',
    args: {
      genre: t.arg({ type: 'Genre', description: 'Filter by literary genre' }),
      status: t.arg.string({ description: 'Filter by reading status (to-read, read)' }),
      sort: t.arg({ type: BookSortEnum, description: 'Sort field' }),
      order: t.arg({ type: SortOrderEnum, description: 'Sort order' }),
      isFavorite: t.arg.boolean({ description: 'Filter to favorite books only (rated 5 stars)' }),
      hasSeries: t.arg.boolean({ description: 'Filter to books that belong to a series' }),
      offset: t.arg.int({ description: 'Page offset (default 0)', defaultValue: 0 }),
      limit: t.arg.int({ description: 'Page size (default 20)', defaultValue: 20 }),
    },
    resolve: async (_, args) => {
      const sortField = args.sort ?? 'createdAt'
      const needsReviews = sortField === 'myRating' || args.isFavorite === true

      const [allBooks, favoriteBookIds, seriesBookIds, allReviews] = await Promise.all([
        BookQuery.findAll(),
        args.isFavorite === true
          ? ReviewQuery.getFavorites().then(
              (reviews) => new Set(reviews.map(({ bookId }) => bookId)),
            )
          : undefined,
        args.hasSeries === true ? SeriesQuery.allBookIds() : undefined,
        needsReviews ? ReviewQuery.getAll() : undefined,
      ])

      const genre = args.genre ?? undefined
      const status = args.status ? BookStatus(args.status) : undefined
      const sort = sortField === 'myRating' ? ('myRating' as const) : BookSort(sortField)
      const desc = (args.order ? SortOrder(args.order) : 'desc') === 'desc'

      const filtered = allBooks
        .filter((book) => (genre ? book.genre === genre : true))
        .filter((book) => (status ? book.status === status : true))
        .filter((book) => (favoriteBookIds ? favoriteBookIds.has(book.id) : true))
        .filter((book) => (seriesBookIds ? seriesBookIds.has(book.id) : true))

      const ratingByBookId =
        sort === 'myRating' && allReviews ? keyBy(allReviews, ({ bookId }) => bookId) : undefined

      const sorted = sortBy(filtered, (book) =>
        match(sort)
          .with('title', () => book.title.toLowerCase())
          .with('author', () => (book.authors[0] ?? '').toLowerCase())
          .with('awards', () => awardsCount(book.awards))
          .with('genre', () => (book.genre ?? '').toLowerCase())
          .with('myRating', () => ratingByBookId?.[book.id]?.rating ?? -1)
          .with('createdAt', () => book.createdAt.getTime())
          .exhaustive(),
      )

      const ordered = desc ? sorted.reverse() : sorted
      const offset = args.offset ?? 0
      const limit = args.limit ?? 20
      const items = ordered.slice(offset, offset + limit)

      return { items, totalCount: ordered.length, hasMore: offset + limit < ordered.length }
    },
  }),
)

builder.queryField('book', (t) =>
  t.field({
    type: BookType,
    nullable: true,
    description: 'Book detail by ID',
    args: {
      id: t.arg({ type: 'BookId', required: true, description: 'Book ID' }),
    },
    resolve: async (_, { id }) => {
      const result = await BookQuery.getById(id)
      return result === 'not-found' ? null : result
    },
  }),
)
