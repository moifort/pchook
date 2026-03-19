import { BookCommand } from '~/domain/book/command'
import { BookQuery } from '~/domain/book/query'
import type { Book, BookId, BookTitle } from '~/domain/book/types'
import { ReviewCommand } from '~/domain/review/command'
import { SeriesCommand } from '~/domain/series/command'
import { Position } from '~/domain/series/primitives'

export namespace BookUseCase {
  export const addFromScan = async (
    title: BookTitle,
    data: Partial<Book>,
    seriesInfo?: { name: string; number?: number },
    coverImageBase64?: string,
  ) => {
    const existing =
      (data.isbn ? await BookQuery.findByISBN(data.isbn) : undefined) ??
      (await BookQuery.findByTitleAndAuthors(String(title), (data.authors ?? []).map(String)))

    if (existing) return { tag: 'duplicate', book: existing } as const

    const book = await BookCommand.add(title, data)

    if (coverImageBase64) {
      await BookCommand.saveImage(book.id, coverImageBase64)
    }

    if (seriesInfo?.name) {
      const series = await SeriesCommand.findOrCreate(seriesInfo.name)
      await SeriesCommand.addBook(series.id, book.id, Position(seriesInfo.number ?? 1))
    }

    return { tag: 'created', book } as const
  }

  export const replaceFromScan = async (
    existingBookId: BookId,
    title: BookTitle,
    data: Partial<Book>,
    seriesInfo?: { name: string; number?: number },
    coverImageBase64?: string,
  ) => {
    const existing = await BookQuery.getById(existingBookId)
    if (existing === 'not-found') return { tag: 'not-found' } as const

    const updated = await BookCommand.update(existingBookId, {
      title,
      authors: data.authors,
      status: data.status,
      publisher: data.publisher,
      publishedDate: data.publishedDate,
      pageCount: data.pageCount,
      genre: data.genre,
      synopsis: data.synopsis,
      isbn: data.isbn,
      language: data.language,
      format: data.format,
      translator: data.translator,
      estimatedPrice: data.estimatedPrice,
      duration: data.duration,
      narrators: data.narrators,
      awards: data.awards,
      publicRatings: data.publicRatings,
    })

    if (updated === 'not-found') return { tag: 'not-found' } as const

    if (coverImageBase64) {
      await BookCommand.saveImage(existingBookId, coverImageBase64)
    }

    await SeriesCommand.removeBook(existingBookId)
    if (seriesInfo?.name) {
      const series = await SeriesCommand.findOrCreate(seriesInfo.name)
      await SeriesCommand.addBook(series.id, existingBookId, Position(seriesInfo.number ?? 1))
    }

    return { tag: 'replaced', book: updated } as const
  }

  export const removeCompletely = async (id: BookId) => {
    const result = await BookCommand.remove(id)
    if (result === 'not-found') return 'not-found' as const
    await Promise.all([ReviewCommand.removeBook(id), SeriesCommand.removeBook(id)])
    return undefined
  }
}
