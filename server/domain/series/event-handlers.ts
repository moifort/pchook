import type { BookRemovedEvent } from '~/domain/book/events'
import { SeriesCommand } from '~/domain/series/command'
import { on } from '~/system/event-bus'

export const registerSeriesEventHandlers = () => {
  on<BookRemovedEvent>('book-removed', async ({ bookId }) => {
    await SeriesCommand.removeBook(bookId)
  })
}
