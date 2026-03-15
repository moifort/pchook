import type { Brand } from 'ts-brand'
import type { Award, BookId, BookTitle, Genre, PublicRating } from '~/domain/book/types'
import type { PersonName } from '~/domain/shared/types'

export type SuggestionId = Brand<string, 'SuggestionId'>

export type Suggestion = {
  id: SuggestionId
  sourceBookId: BookId
  title: BookTitle
  authors: PersonName[]
  genre?: Genre
  synopsis?: string
  awards: Award[]
  publicRatings: PublicRating[]
  createdAt: Date
}
