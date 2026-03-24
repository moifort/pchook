import { BookId, BookSort, BookStatus, Genre, SortOrder } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import { BookListReadModel } from '~/domain/book/read-model/list'
import { builder } from '~/domain/shared/graphql/builder'
import { BookSortEnum, SortOrderEnum } from './enums'
import { BookListItemType, BookType } from './types'

builder.objectField(BookType, 'coverImageUrl', (t) =>
  t.string({
    nullable: true,
    description: 'Cover image URL',
    resolve: ({ coverImageId }) => (coverImageId ? `/images/${coverImageId}` : null),
  }),
)

builder.queryField('books', (t) =>
  t.field({
    type: [BookListItemType],
    description: 'Book list with filters and sorting',
    args: {
      genre: t.arg.string({ description: 'Filter by literary genre' }),
      status: t.arg.string({ description: 'Filter by reading status (to-read, read)' }),
      sort: t.arg({ type: BookSortEnum, description: 'Sort field' }),
      order: t.arg({ type: SortOrderEnum, description: 'Sort order' }),
    },
    resolve: (_, args) =>
      BookListReadModel.all({
        genre: args.genre ? Genre(args.genre) : undefined,
        status: args.status ? BookStatus(args.status) : undefined,
        sort: args.sort ? BookSort(args.sort) : undefined,
        order: args.order ? SortOrder(args.order) : undefined,
      }),
  }),
)

builder.queryField('book', (t) =>
  t.field({
    type: BookType,
    nullable: true,
    description: 'Book detail by ID',
    args: {
      id: t.arg.id({ required: true, description: 'Book ID' }),
    },
    resolve: async (_, { id }) => {
      const result = await BookQuery.getById(BookId(id))
      return result === 'not-found' ? null : result
    },
  }),
)
