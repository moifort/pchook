import type { DashboardView, FavoriteBook, RecentAward, RecentBook } from '~/domain/dashboard/types'
import { builder } from '~/domain/shared/graphql/builder'

const BookCountType = builder.objectRef<DashboardView['bookCount']>('BookCount').implement({
  description: 'Book count by status',
  fields: (t) => ({
    total: t.exposeInt('total', { description: 'Total number of books' }),
    toRead: t.exposeInt('toRead', { description: 'Books to read' }),
    read: t.exposeInt('read', { description: 'Books read' }),
  }),
})

const FavoriteBookType = builder.objectRef<FavoriteBook>('FavoriteBook').implement({
  description: 'Favorite book (top-rated)',
  fields: (t) => ({
    id: t.id({ description: 'Book ID', resolve: ({ id }) => String(id) }),
    title: t.exposeString('title', { description: 'Title' }),
    authors: t.stringList({
      description: 'Authors',
      resolve: ({ authors }) => authors.map(String),
    }),
    genre: t.string({
      nullable: true,
      description: 'Genre',
      resolve: ({ genre }) => (genre ? String(genre) : null),
    }),
    rating: t.int({ description: 'Rating (0-10)', resolve: ({ rating }) => Number(rating) }),
    readDate: t.string({
      nullable: true,
      description: 'Read date (ISO 8601)',
      resolve: ({ readDate }) => readDate?.toISOString() ?? null,
    }),
    estimatedPrice: t.float({
      nullable: true,
      description: 'Estimated price in euros',
      resolve: ({ estimatedPrice }) => (estimatedPrice ? Number(estimatedPrice) : null),
    }),
  }),
})

const RecentBookType = builder.objectRef<RecentBook>('RecentBook').implement({
  description: 'Recently added book',
  fields: (t) => ({
    id: t.id({ description: 'Book ID', resolve: ({ id }) => String(id) }),
    title: t.exposeString('title', { description: 'Title' }),
    authors: t.stringList({
      description: 'Authors',
      resolve: ({ authors }) => authors.map(String),
    }),
    genre: t.string({
      nullable: true,
      description: 'Genre',
      resolve: ({ genre }) => (genre ? String(genre) : null),
    }),
    createdAt: t.string({
      description: 'Date added (ISO 8601)',
      resolve: ({ createdAt }) => createdAt.toISOString(),
    }),
  }),
})

const RecentAwardType = builder.objectRef<RecentAward>('RecentAward').implement({
  description: 'Recent literary award',
  fields: (t) => ({
    bookTitle: t.exposeString('bookTitle', { description: 'Book title' }),
    authors: t.stringList({
      description: 'Authors',
      resolve: ({ authors }) => authors.map(String),
    }),
    awardName: t.exposeString('awardName', { description: 'Award name' }),
    awardYear: t.exposeInt('awardYear', { description: 'Award year' }),
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
    recentAwards: t.field({
      type: [RecentAwardType],
      description: 'Recent literary awards',
      resolve: ({ recentAwards }) => recentAwards,
    }),
  }),
})
