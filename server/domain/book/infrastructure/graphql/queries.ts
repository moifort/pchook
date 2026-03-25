import { getRequestURL } from 'h3'
import { sortBy } from 'lodash-es'
import { match } from 'ts-pattern'
import { awardsCount } from '~/domain/book/business-rules'
import { BookSort, BookStatus, SortOrder } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import { builder } from '~/domain/shared/graphql/builder'
import { Url } from '~/domain/shared/primitives'
import { BookSortEnum, SortOrderEnum } from './enums'
import { BookType } from './types'

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
    type: [BookType],
    description: 'Book list with filters and sorting',
    args: {
      genre: t.arg({ type: 'Genre', description: 'Filter by literary genre' }),
      status: t.arg.string({ description: 'Filter by reading status (to-read, read)' }),
      sort: t.arg({ type: BookSortEnum, description: 'Sort field' }),
      order: t.arg({ type: SortOrderEnum, description: 'Sort order' }),
    },
    resolve: async (_, args) => {
      const allBooks = await BookQuery.findAll()

      const genre = args.genre ?? undefined
      const status = args.status ? BookStatus(args.status) : undefined
      const sort = args.sort ? BookSort(args.sort) : 'createdAt'
      const desc = (args.order ? SortOrder(args.order) : 'desc') === 'desc'

      const filtered = allBooks
        .filter((book) => (genre ? book.genre === genre : true))
        .filter((book) => (status ? book.status === status : true))

      const sorted = sortBy(filtered, (book) =>
        match(sort)
          .with('title', () => book.title.toLowerCase())
          .with('author', () => (book.authors[0] ?? '').toLowerCase())
          .with('awards', () => awardsCount(book.awards))
          .with('genre', () => (book.genre ?? '').toLowerCase())
          .with('createdAt', () => book.createdAt.getTime())
          .exhaustive(),
      )

      return desc ? sorted.reverse() : sorted
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
