import { BookId, BookSort, BookStatus, Genre, SortOrder } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import { BookListReadModel } from '~/domain/book/read-model/list'
import { builder } from '~/domain/shared/graphql/builder'
import { BookSortEnum, SortOrderEnum } from './enums'
import { BookListItemType, BookType } from './types'

builder.objectField(BookType, 'coverImageUrl', (t) =>
  t.string({
    nullable: true,
    description: "URL de l'image de couverture",
    resolve: ({ coverImageId }) => (coverImageId ? `/images/${coverImageId}` : null),
  }),
)

builder.queryField('books', (t) =>
  t.field({
    type: [BookListItemType],
    description: 'Liste des livres avec filtres et tri',
    args: {
      genre: t.arg.string({ description: 'Filtrer par genre littéraire' }),
      status: t.arg.string({ description: 'Filtrer par statut de lecture (to-read, read)' }),
      sort: t.arg({ type: BookSortEnum, description: 'Champ de tri' }),
      order: t.arg({ type: SortOrderEnum, description: 'Ordre de tri' }),
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
    description: "Détail d'un livre par son identifiant",
    args: {
      id: t.arg.id({ required: true, description: 'Identifiant du livre' }),
    },
    resolve: async (_, { id }) => {
      const result = await BookQuery.getById(BookId(id))
      return result === 'not-found' ? null : result
    },
  }),
)
