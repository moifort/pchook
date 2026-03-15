import { BookCommand } from '~/domain/book/command'
import type { Book, BookId, BookTitle } from '~/domain/book/types'
import { ReviewCommand } from '~/domain/review/command'
import { SeriesCommand } from '~/domain/series/command'
import { Position } from '~/domain/series/primitives'
import { SuggestionCommand } from '~/domain/suggestion/command'
import { createLogger } from '~/system/logger'
import { SuggestionGenerator } from '~/system/suggestion/index'

const log = createLogger('book-use-case')

export namespace BookUseCase {
  export const addFromScan = async (
    title: BookTitle,
    data: Partial<Book>,
    seriesInfo?: { name: string; number?: number },
    coverImageBase64?: string,
  ) => {
    const book = await BookCommand.add(title, data)

    if (coverImageBase64) {
      await BookCommand.saveImage(book.id, coverImageBase64)
    }

    if (seriesInfo?.name) {
      const series = await SeriesCommand.findOrCreate(seriesInfo.name)
      await SeriesCommand.addBook(series.id, book.id, Position(seriesInfo.number ?? 1))
    }

    // Generate suggestions in background
    void generateSuggestionsInBackground(book)

    return book
  }

  export const removeCompletely = async (id: BookId) => {
    const result = await BookCommand.remove(id)
    if (result === 'not-found') return 'not-found' as const
    await Promise.all([
      ReviewCommand.removeBook(id),
      SeriesCommand.removeBook(id),
      SuggestionCommand.clearForBook(id),
    ])
    return undefined
  }

  const generateSuggestionsInBackground = async (book: Book) => {
    try {
      const suggestions = await SuggestionGenerator.generate(
        book.id,
        String(book.title),
        book.authors.map(String),
        book.genre ? String(book.genre) : undefined,
      )
      if (suggestions.length > 0) {
        await SuggestionCommand.saveAll(suggestions)
      }
    } catch (error) {
      log.error('Failed to generate suggestions for book', book.id, error)
    }
  }
}
