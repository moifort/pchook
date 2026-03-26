import type { BookId, Genre, Language } from '~/domain/book/types'
import type { SeriesId, SeriesName } from '~/domain/series/types'
import type { PersonName } from '~/domain/shared/types'

export type FavoriteBook = {
  id: BookId
  title: string
  authors: PersonName[]
  genre?: Genre
  language?: Language
}

export type RecentBook = {
  id: BookId
  title: string
  authors: PersonName[]
  genre?: Genre
  language?: Language
}

export type RecommendedBook = {
  id: BookId
  title: string
  authors: PersonName[]
  genre?: Genre
  language?: Language
  recommendedBy: PersonName
}

export type FavoriteSeries = {
  id: SeriesId
  name: SeriesName
  volumeCount: number
  authors: PersonName[]
  language: Language | undefined
  firstBookId: BookId | undefined
}

export type DashboardView = {
  bookCount: {
    total: number
    toRead: number
    read: number
    totalAudioMinutes: number
  }
  favorites: FavoriteBook[]
  recentBooks: RecentBook[]
  recommendedBooks: RecommendedBook[]
  favoriteSeries: FavoriteSeries[]
}
