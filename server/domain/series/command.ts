import type { BookId } from '~/domain/book/types'
import { randomSeriesId, SeriesName } from '~/domain/series/primitives'
import * as repository from '~/domain/series/repository'
import type { SeriesId, SeriesLabel, SeriesPosition } from '~/domain/series/types'

export namespace SeriesCommand {
  export const findOrCreate = async (name: string) => {
    const existing = await repository.findSeriesByName(name)
    if (existing) return existing
    return await repository.saveSeries({
      id: randomSeriesId(),
      name: SeriesName(name),
      createdAt: new Date(),
    })
  }

  export const addBook = async (
    seriesId: SeriesId,
    bookId: BookId,
    label: SeriesLabel,
    position: SeriesPosition,
  ) => {
    return await repository.saveSeriesBook({
      seriesId,
      bookId,
      label,
      position,
      addedAt: new Date(),
    })
  }

  export const removeBook = async (bookId: BookId) => {
    await repository.removeAllSeriesBooksForBook(bookId)
  }
}
