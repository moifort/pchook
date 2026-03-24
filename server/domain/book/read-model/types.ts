import type { Book, BookId } from '~/domain/book/types'
import type { Review } from '~/domain/review/types'

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
  series?: SeriesInfo
  review?: Review
}
