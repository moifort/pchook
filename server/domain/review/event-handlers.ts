import type { BookRemovedEvent } from '~/domain/book/events'
import { ReviewCommand } from '~/domain/review/command'
import { on } from '~/system/event-bus'

export const registerReviewEventHandlers = () => {
  on<BookRemovedEvent>('book-removed', async ({ bookId }) => {
    await ReviewCommand.removeBook(bookId)
  })
}
