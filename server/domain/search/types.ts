import type { BookId, Language } from '~/domain/book/types'
import type { SeriesId } from '~/domain/series/types'

export type SearchEntryType = 'book' | 'series' | 'author'

export type SearchEntry = {
  type: SearchEntryType
  entityId: string
  text: string
  normalizedText: string
}

export type BookSearchResult = {
  id: BookId
  title: string
  authors: string[]
  language?: Language
  status: string
  coverImageId?: string
}

export type SeriesSearchResult = {
  id: SeriesId
  name: string
  volumeCount: number
  rating?: number
  languages: Language[]
}

export type AuthorSearchResult = {
  name: string
  bookCount: number
  firstBookId: BookId
}

export type SearchResults = {
  books: BookSearchResult[]
  series: SeriesSearchResult[]
  authors: AuthorSearchResult[]
}
