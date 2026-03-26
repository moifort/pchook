import { BookCommand } from '~/domain/book/command'
import type { BookRemovedEvent } from '~/domain/book/events'
import { BookQuery } from '~/domain/book/query'
import type { Book, BookId, BookTitle } from '~/domain/book/types'
import { ImageCommand } from '~/domain/image/command'
import { SeriesCommand } from '~/domain/series/command'
import { SeriesLabel, SeriesPosition } from '~/domain/series/primitives'
import { emit } from '~/system/event-bus'

type SeriesInfo = { name: string; label?: string; number?: number }

const toSeriesLabelAndPosition = (info: SeriesInfo) => ({
  label: SeriesLabel(info.label ?? String(info.number ?? 1)),
  position: SeriesPosition(info.number ?? 1),
})

export namespace BookUseCase {
  export const addFromScan = async (
    title: BookTitle,
    data: Partial<Book>,
    seriesInfo?: SeriesInfo,
    coverImageBuffer?: Buffer,
  ) => {
    const existing =
      (data.isbn ? await BookQuery.findByISBN(data.isbn) : undefined) ??
      (await BookQuery.findByTitleAndAuthors(title, data.authors ?? [], data.language))

    if (existing) return { tag: 'duplicate', book: existing } as const

    const coverImageId = coverImageBuffer ? await ImageCommand.save(coverImageBuffer) : undefined

    const book = await BookCommand.add(title, { ...data, coverImageId })

    if (seriesInfo?.name) {
      const series = await SeriesCommand.findOrCreate(seriesInfo.name)
      const { label, position } = toSeriesLabelAndPosition(seriesInfo)
      await SeriesCommand.addBook(series.id, book.id, label, position)
    }

    return { tag: 'created', book } as const
  }

  export const replaceFromScan = async (
    existingBookId: BookId,
    title: BookTitle,
    data: Partial<Book>,
    seriesInfo?: SeriesInfo,
    coverImageBuffer?: Buffer,
  ) => {
    const existing = await BookQuery.getById(existingBookId)
    if (existing === 'not-found') return { tag: 'not-found' } as const

    const coverImageId = coverImageBuffer ? await ImageCommand.save(coverImageBuffer) : undefined

    if (existing.coverImageId && coverImageId) {
      await ImageCommand.remove(existing.coverImageId)
    }

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
      durationMinutes: data.durationMinutes,
      narrators: data.narrators,
      awards: data.awards,
      publicRatings: data.publicRatings,
      ...(coverImageId ? { coverImageId } : {}),
    })

    if (updated === 'not-found') return { tag: 'not-found' } as const

    await SeriesCommand.removeBook(existingBookId)
    if (seriesInfo?.name) {
      const series = await SeriesCommand.findOrCreate(seriesInfo.name)
      const { label, position } = toSeriesLabelAndPosition(seriesInfo)
      await SeriesCommand.addBook(series.id, existingBookId, label, position)
    }

    return { tag: 'replaced', book: updated } as const
  }

  export const removeCompletely = async (id: BookId) => {
    const book = await BookQuery.getById(id)
    if (book === 'not-found') return 'not-found' as const

    if (book.coverImageId) {
      await ImageCommand.remove(book.coverImageId)
    }

    const result = await BookCommand.remove(id)
    if (result === 'not-found') return 'not-found' as const
    await emit<BookRemovedEvent>('book-removed', { bookId: id })
    return undefined
  }
}
