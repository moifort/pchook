import { BookId, BookSort, BookStatus, Genre, SortOrder } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import { ReviewQuery } from '~/domain/review/query'
import { booksInLanguage } from '~/domain/series/business-rules'
import { SeriesQuery } from '~/domain/series/query'
import { builder } from '~/graphql/builder'
import { BookListItemType, BookType } from '~/graphql/types/book'
import { BookSortEnum, SortOrderEnum } from '~/graphql/types/enums'
import { ReviewType } from '~/graphql/types/review'
import { SeriesInfoType } from '~/graphql/types/series'
import type { SeriesInfo } from '~/read-model/book-detail/types'
import { BookListReadModel } from '~/read-model/book-list/index'

builder.objectField(BookType, 'review', (t) =>
  t.field({
    type: ReviewType,
    nullable: true,
    description: 'Critique et note personnelle',
    resolve: async ({ id }) => {
      const result = await ReviewQuery.getByBookId(id)
      return result === 'not-found' ? null : result
    },
  }),
)

builder.objectField(BookType, 'series', (t) =>
  t.field({
    type: SeriesInfoType,
    nullable: true,
    description: 'Informations sur la série',
    resolve: async ({ id, language }) => {
      const seriesInfo = await SeriesQuery.getByBookId(id)
      if (!seriesInfo) return null

      const fullSeries = await SeriesQuery.getById(seriesInfo.id)
      if (fullSeries === 'not-found') return null

      return {
        name: String(fullSeries.name),
        label: String(seriesInfo.label),
        position: Number(seriesInfo.position),
        books: booksInLanguage(fullSeries.books, language).map(
          ({ id, title, label, position }) => ({
            id,
            title: String(title),
            label: String(label),
            position: Number(position),
          }),
        ),
      } satisfies SeriesInfo
    },
  }),
)

builder.objectField(BookType, 'coverImageBase64', (t) =>
  t.string({
    nullable: true,
    description: 'Image de couverture encodée en base64',
    resolve: ({ id }) => BookQuery.getImageById(id),
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
