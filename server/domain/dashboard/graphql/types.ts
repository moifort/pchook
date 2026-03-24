import type { DashboardView, FavoriteBook, RecentAward, RecentBook } from '~/domain/dashboard/types'
import { builder } from '~/domain/shared/graphql/builder'

const BookCountType = builder.objectRef<DashboardView['bookCount']>('BookCount').implement({
  description: 'Compteur de livres par statut',
  fields: (t) => ({
    total: t.exposeInt('total', { description: 'Nombre total de livres' }),
    toRead: t.exposeInt('toRead', { description: 'Livres à lire' }),
    read: t.exposeInt('read', { description: 'Livres lus' }),
  }),
})

const FavoriteBookType = builder.objectRef<FavoriteBook>('FavoriteBook').implement({
  description: 'Livre favori (note coup de cœur)',
  fields: (t) => ({
    id: t.id({ description: 'Identifiant du livre', resolve: ({ id }) => String(id) }),
    title: t.exposeString('title', { description: 'Titre' }),
    authors: t.stringList({
      description: 'Auteurs',
      resolve: ({ authors }) => authors.map(String),
    }),
    genre: t.string({
      nullable: true,
      description: 'Genre',
      resolve: ({ genre }) => (genre ? String(genre) : null),
    }),
    rating: t.int({ description: 'Note (0-10)', resolve: ({ rating }) => Number(rating) }),
    readDate: t.string({
      nullable: true,
      description: 'Date de lecture (ISO 8601)',
      resolve: ({ readDate }) => readDate?.toISOString() ?? null,
    }),
    estimatedPrice: t.float({
      nullable: true,
      description: 'Prix estimé en euros',
      resolve: ({ estimatedPrice }) => (estimatedPrice ? Number(estimatedPrice) : null),
    }),
  }),
})

const RecentBookType = builder.objectRef<RecentBook>('RecentBook').implement({
  description: 'Livre récemment ajouté',
  fields: (t) => ({
    id: t.id({ description: 'Identifiant du livre', resolve: ({ id }) => String(id) }),
    title: t.exposeString('title', { description: 'Titre' }),
    authors: t.stringList({
      description: 'Auteurs',
      resolve: ({ authors }) => authors.map(String),
    }),
    genre: t.string({
      nullable: true,
      description: 'Genre',
      resolve: ({ genre }) => (genre ? String(genre) : null),
    }),
    createdAt: t.string({
      description: "Date d'ajout (ISO 8601)",
      resolve: ({ createdAt }) => createdAt.toISOString(),
    }),
  }),
})

const RecentAwardType = builder.objectRef<RecentAward>('RecentAward').implement({
  description: 'Prix littéraire récent',
  fields: (t) => ({
    bookTitle: t.exposeString('bookTitle', { description: 'Titre du livre' }),
    authors: t.stringList({
      description: 'Auteurs',
      resolve: ({ authors }) => authors.map(String),
    }),
    awardName: t.exposeString('awardName', { description: 'Nom du prix' }),
    awardYear: t.exposeInt('awardYear', { description: 'Année du prix' }),
  }),
})

export const DashboardViewType = builder.objectRef<DashboardView>('DashboardView').implement({
  description: 'Vue tableau de bord avec statistiques de lecture',
  fields: (t) => ({
    bookCount: t.field({
      type: BookCountType,
      description: 'Compteur de livres',
      resolve: ({ bookCount }) => bookCount,
    }),
    favorites: t.field({
      type: [FavoriteBookType],
      description: 'Livres favoris',
      resolve: ({ favorites }) => favorites,
    }),
    recentBooks: t.field({
      type: [RecentBookType],
      description: 'Livres récemment ajoutés',
      resolve: ({ recentBooks }) => recentBooks,
    }),
    recentAwards: t.field({
      type: [RecentAwardType],
      description: 'Prix littéraires récents',
      resolve: ({ recentAwards }) => recentAwards,
    }),
  }),
})
