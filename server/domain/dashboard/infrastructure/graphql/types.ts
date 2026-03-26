import { LanguageEnum } from '~/domain/book/infrastructure/graphql/enums'
import type {
  DashboardView,
  FavoriteBook,
  FavoriteSeries,
  RecentBook,
  RecommendedBook,
} from '~/domain/dashboard/types'
import { builder } from '~/domain/shared/graphql/builder'

const BookCountType = builder.objectRef<DashboardView['bookCount']>('BookCount').implement({
  description: 'Book count by status',
  fields: (t) => ({
    total: t.exposeInt('total', { description: 'Total number of books' }),
    toRead: t.exposeInt('toRead', { description: 'Books to read' }),
    read: t.exposeInt('read', { description: 'Books read' }),
    totalAudioMinutes: t.exposeInt('totalAudioMinutes', {
      description: 'Total audiobook duration in minutes',
    }),
  }),
})

const FavoriteBookType = builder.objectRef<FavoriteBook>('FavoriteBook').implement({
  description: 'Favorite book (rated 5)',
  fields: (t) => ({
    id: t.field({ type: 'BookId', description: 'Book ID', resolve: ({ id }) => id }),
    title: t.exposeString('title', { description: 'Title' }),
    authors: t.field({
      type: ['PersonName'],
      description: 'Authors',
      resolve: ({ authors }) => authors,
    }),
    genre: t.field({
      type: 'Genre',
      nullable: true,
      description: 'Genre',
      resolve: ({ genre }) => genre ?? null,
    }),
    language: t.field({
      type: LanguageEnum,
      nullable: true,
      description: 'Language',
      resolve: ({ language }) => language ?? null,
    }),
  }),
})

const RecentBookType = builder.objectRef<RecentBook>('RecentBook').implement({
  description: 'Recently added book',
  fields: (t) => ({
    id: t.field({ type: 'BookId', description: 'Book ID', resolve: ({ id }) => id }),
    title: t.exposeString('title', { description: 'Title' }),
    authors: t.field({
      type: ['PersonName'],
      description: 'Authors',
      resolve: ({ authors }) => authors,
    }),
    genre: t.field({
      type: 'Genre',
      nullable: true,
      description: 'Genre',
      resolve: ({ genre }) => genre ?? null,
    }),
    language: t.field({
      type: LanguageEnum,
      nullable: true,
      description: 'Language',
      resolve: ({ language }) => language ?? null,
    }),
  }),
})

const RecommendedBookType = builder.objectRef<RecommendedBook>('RecommendedBook').implement({
  description: 'Book recommended by someone',
  fields: (t) => ({
    id: t.field({ type: 'BookId', description: 'Book ID', resolve: ({ id }) => id }),
    title: t.exposeString('title', { description: 'Title' }),
    authors: t.field({
      type: ['PersonName'],
      description: 'Authors',
      resolve: ({ authors }) => authors,
    }),
    genre: t.field({
      type: 'Genre',
      nullable: true,
      description: 'Genre',
      resolve: ({ genre }) => genre ?? null,
    }),
    language: t.field({
      type: LanguageEnum,
      nullable: true,
      description: 'Language',
      resolve: ({ language }) => language ?? null,
    }),
    recommendedBy: t.field({
      type: 'PersonName',
      description: 'Name of recommender',
      resolve: ({ recommendedBy }) => recommendedBy,
    }),
  }),
})

const FavoriteSeriesType = builder.objectRef<FavoriteSeries>('FavoriteSeries').implement({
  description: 'Favorite series (rated 5)',
  fields: (t) => ({
    id: t.id({ description: 'Series ID', resolve: ({ id }) => id }),
    name: t.exposeString('name', { description: 'Series name' }),
    volumeCount: t.exposeInt('volumeCount', { description: 'Number of volumes' }),
    authors: t.field({
      type: ['PersonName'],
      description: 'Authors',
      resolve: ({ authors }) => authors,
    }),
    language: t.field({
      type: LanguageEnum,
      nullable: true,
      description: 'Language',
      resolve: ({ language }) => language ?? null,
    }),
    firstBookId: t.field({
      type: 'BookId',
      nullable: true,
      description: 'First volume book ID for navigation',
      resolve: ({ firstBookId }) => firstBookId ?? null,
    }),
  }),
})

export const DashboardViewType = builder.objectRef<DashboardView>('DashboardView').implement({
  description: 'Dashboard view with reading statistics',
  fields: (t) => ({
    bookCount: t.field({
      type: BookCountType,
      description: 'Book count',
      resolve: ({ bookCount }) => bookCount,
    }),
    favorites: t.field({
      type: [FavoriteBookType],
      description: 'Favorite books',
      resolve: ({ favorites }) => favorites,
    }),
    recentBooks: t.field({
      type: [RecentBookType],
      description: 'Recently added books',
      resolve: ({ recentBooks }) => recentBooks,
    }),
    recommendedBooks: t.field({
      type: [RecommendedBookType],
      description: 'Books recommended by others',
      resolve: ({ recommendedBooks }) => recommendedBooks,
    }),
    favoriteSeries: t.field({
      type: [FavoriteSeriesType],
      description: 'Favorite series',
      resolve: ({ favoriteSeries }) => favoriteSeries,
    }),
  }),
})
