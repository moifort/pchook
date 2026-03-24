import type { Award, Book, BookId, BookStatus, Genre, Note } from '~/domain/book/types'
import type { Review } from '~/domain/review/types'
import type { Eur, PersonName } from '~/domain/shared/types'

export type BookListItem = {
  id: BookId
  title: string
  authors: PersonName[]
  genre?: Genre
  status: BookStatus
  estimatedPrice?: Eur
  awards: Award[]
  rating?: Note
  language?: string
  seriesName?: string
  seriesLabel?: string
  seriesPosition?: number
  createdAt: Date
}

export type SeriesInfo = {
  name: string
  label: string
  position: number
  books: {
    id: BookId
    title: string
    label: string
    position: number
  }[]
}

export type BookDetailView = {
  book: Book
  coverImageBase64?: string
  series?: SeriesInfo
  review?: Review
}
