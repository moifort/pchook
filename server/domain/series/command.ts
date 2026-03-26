import type { BookId, Note } from '~/domain/book/types'
import * as repository from '~/domain/series/infrastructure/repository'
import { randomSeriesId, SeriesName } from '~/domain/series/primitives'
import type {
  SeriesId,
  SeriesLabel,
  SeriesName as SeriesNameType,
  SeriesPosition,
} from '~/domain/series/types'

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

  export const rateSeries = async (seriesId: SeriesId, rating: Note) => {
    const series = await repository.findSeriesBy(seriesId)
    if (!series) return 'not-found' as const
    const updated = { ...series, rating }
    await repository.saveSeries(updated)
    return updated
  }

  export const renameSeries = async (seriesId: SeriesId, newName: SeriesNameType) => {
    const series = await repository.findSeriesBy(seriesId)
    if (!series) return 'not-found' as const
    const existing = await repository.findSeriesByName(newName)
    if (existing && existing.id !== seriesId) return 'name-taken' as const
    repository.removeFromNameIndex(series.name)
    const updated = { ...series, name: newName }
    await repository.saveSeries(updated)
    return updated
  }
}
