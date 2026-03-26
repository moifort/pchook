import type { BookId } from '~/domain/book/types'

export type BookAddedEvent = {
  bookId: BookId
}

export type BookUpdatedEvent = {
  bookId: BookId
}

export type BookRemovedEvent = {
  bookId: BookId
}
