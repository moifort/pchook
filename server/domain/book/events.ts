import type { BookId } from '~/domain/book/types'

export type BookRemovedEvent = {
  bookId: BookId
}
