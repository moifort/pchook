import type { BookId, Note } from '~/domain/book/types'

export type Review = {
  bookId: BookId
  rating: Note
  readDate?: Date
  reviewNotes?: string
  createdAt: Date
}
