import { sortBy } from 'lodash-es'
import { awardsCount } from '~/domain/book/business-rules'
import { BookId, BookSort, BookStatus, Genre, SortOrder } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import { builder } from '~/domain/shared/graphql/builder'
import { BookSortEnum, SortOrderEnum } from './enums'
import { BookType } from './types'

builder.objectField(BookType, 'coverImageUrl', (t) =>
  t.string({
    nullable: true,
    description: 'Cover image URL',
    resolve: ({ coverImageId }) => (coverImageId ? `/images/${coverImageId}` : null),
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

      const genre = args.genre ? Genre(args.genre) : undefined
      const status = args.status ? BookStatus(args.status) : undefined
      const sort = args.sort ? BookSort(args.sort) : 'createdAt'
      const desc = (args.order ? SortOrder(args.order) : 'desc') === 'desc'

      const filtered = allBooks
        .filter((book) => (genre ? book.genre === genre : true))
        .filter((book) => (status ? book.status === status : true))

      const sorted = sortBy(filtered, (book) => {
        if (sort === 'title') return String(book.title).toLowerCase()
        if (sort === 'author') return book.authors[0] ? String(book.authors[0]).toLowerCase() : ''
        if (sort === 'awards') return awardsCount(book.awards)
        if (sort === 'genre') return (book.genre ? String(book.genre) : '').toLowerCase()
        return book.createdAt.getTime()
      })

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
      const result = await BookQuery.getById(BookId(id))
      return result === 'not-found' ? null : result
    },
  }),
)
