import type { BookId } from '~/domain/book/types'
import type { Series, SeriesBook, SeriesId } from '~/domain/series/types'
import { createTypedStorage } from '~/system/storage'

const seriesStorage = () => createTypedStorage<Series>('series')
const seriesBooksStorage = () => createTypedStorage<SeriesBook>('series-books')

// In-memory index to avoid fs driver consistency issues during rapid writes
const seriesByName = new Map<string, Series>()
let seriesIndexLoaded = false

const ensureSeriesIndex = async () => {
  if (seriesIndexLoaded) return
  const all = await findAllSeries()
  for (const series of all) {
    seriesByName.set(series.name.toLowerCase(), series)
  }
  seriesIndexLoaded = true
}

export const findAllSeries = async () => {
  const keys = await seriesStorage().getKeys()
  const items = await seriesStorage().getItems(keys)
  return items.map(({ value }) => value)
}

export const findSeriesBy = (id: SeriesId) => seriesStorage().getItem(id)

export const findSeriesByName = async (name: string) => {
  await ensureSeriesIndex()
  return seriesByName.get(name.toLowerCase()) ?? null
}

export const saveSeries = async (series: Series) => {
  await seriesStorage().setItem(series.id, series)
  seriesByName.set(series.name.toLowerCase(), series)
  return series
}

export const removeSeries = async (id: SeriesId) => {
  await seriesStorage().removeItem(id)
  for (const [key, series] of seriesByName) {
    if (series.id === id) {
      seriesByName.delete(key)
      break
    }
  }
}

export const findAllSeriesBooks = async () => {
  const keys = await seriesBooksStorage().getKeys()
  const items = await seriesBooksStorage().getItems(keys)
  return items.map(({ value }) => value)
}

export const findSeriesBooksBySeriesId = async (seriesId: SeriesId) => {
  const all = await findAllSeriesBooks()
  return all.filter((sb) => sb.seriesId === seriesId)
}

export const findSeriesBookByBookId = async (bookId: BookId) => {
  const all = await findAllSeriesBooks()
  return all.find((sb) => sb.bookId === bookId) ?? null
}

export const saveSeriesBook = async (entry: SeriesBook) => {
  await seriesBooksStorage().setItem(`${entry.seriesId}:${entry.bookId}`, entry)
  return entry
}

export const removeAllSeriesBooksForBook = async (bookId: BookId) => {
  const entry = await findSeriesBookByBookId(bookId)
  if (entry) await seriesBooksStorage().removeItem(`${entry.seriesId}:${entry.bookId}`)
}
