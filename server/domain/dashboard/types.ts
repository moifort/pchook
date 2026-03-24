import type { BookId, Genre, Note } from '~/domain/book/types'
import type { Eur, PersonName } from '~/domain/shared/types'

export type FavoriteBook = {
  id: BookId
  title: string
  authors: PersonName[]
  genre?: Genre
  rating: Note
  readDate?: Date
  estimatedPrice?: Eur
}

export type RecentBook = {
  id: BookId
  title: string
  authors: PersonName[]
  genre?: Genre
  createdAt: Date
}

export type RecentAward = {
  bookTitle: string
  authors: PersonName[]
  awardName: string
  awardYear: number
}

export type DashboardView = {
  bookCount: {
    total: number
    toRead: number
    read: number
  }
  favorites: FavoriteBook[]
  recentBooks: RecentBook[]
  recentAwards: RecentAward[]
}
