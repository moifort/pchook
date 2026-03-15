import type { Book, BookId } from '~/domain/book/types'
import type { Review } from '~/domain/review/types'
import type { Position } from '~/domain/series/types'
import type { Suggestion } from '~/domain/suggestion/types'

export type SeriesInfo = {
  name: string
  position: Position
  books: {
    id: BookId
    title: string
    position: Position
  }[]
}

export type BookDetailView = {
  book: Book
  coverImageBase64?: string
  series?: SeriesInfo
  review?: Review
  suggestions: Suggestion[]
}
