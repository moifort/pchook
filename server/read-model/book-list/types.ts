import type { Award, BookId, BookStatus, Genre, Note, PublicRating } from '~/domain/book/types'
import type { Eur, PersonName } from '~/domain/shared/types'

export type BookListItem = {
  id: BookId
  title: string
  authors: PersonName[]
  genre?: Genre
  status: BookStatus
  estimatedPrice?: Eur
  awards: Award[]
  publicRatings: PublicRating[]
  rating?: Note
  language?: string
  seriesName?: string
  seriesLabel?: string
  seriesPosition?: number
  createdAt: Date
}
