import type { BookAddedEvent, BookRemovedEvent, BookUpdatedEvent } from '~/domain/book/events'
import type { BookId } from '~/domain/book/types'
import { SearchCommand } from '~/domain/search/command'
import { on } from '~/system/event-bus'

export const registerSearchEventHandlers = () => {
  on<BookAddedEvent>('book-added', async ({ bookId }) => {
    await SearchCommand.indexBookById(bookId)
    await SearchCommand.rebuildAuthors()
  })

  on<BookUpdatedEvent>('book-updated', async ({ bookId }) => {
    await SearchCommand.indexBookById(bookId)
    await SearchCommand.rebuildAuthors()
  })

  on<BookRemovedEvent>('book-removed', async ({ bookId }) => {
    SearchCommand.removeBook(bookId as BookId)
    await SearchCommand.rebuildAuthors()
    await SearchCommand.rebuildSeries()
  })
}
