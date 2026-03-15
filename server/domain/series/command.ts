import type { BookId } from '~/domain/book/types'
import { randomSeriesId, SeriesName } from '~/domain/series/primitives'
import * as repository from '~/domain/series/repository'
import type { Position, SeriesId } from '~/domain/series/types'

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

  export const addBook = async (seriesId: SeriesId, bookId: BookId, position: Position) => {
    return await repository.saveSeriesBook({
      seriesId,
      bookId,
      position,
      addedAt: new Date(),
    })
  }

  export const removeBook = async (bookId: BookId) => {
    await repository.removeAllSeriesBooksForBook(bookId)
  }
}
