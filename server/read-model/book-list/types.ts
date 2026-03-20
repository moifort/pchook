import type { Award, BookId, BookStatus, Genre, Note } from '~/domain/book/types'
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
