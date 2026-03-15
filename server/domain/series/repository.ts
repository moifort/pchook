import type { BookId } from '~/domain/book/types'
import type { Series, SeriesBook, SeriesId } from '~/domain/series/types'

const seriesStorage = () => useStorage('series')
const seriesBooksStorage = () => useStorage('series-books')

export const findAllSeries = async () => {
  const keys = await seriesStorage().getKeys()
  const items = await seriesStorage().getItems<Series>(keys)
  return items.map(({ value }) => value)
}

export const findSeriesBy = (id: SeriesId) => seriesStorage().getItem<Series>(id)

export const findSeriesByName = async (name: string) => {
  const all = await findAllSeries()
  return all.find((s) => s.name.toLowerCase() === name.toLowerCase()) ?? null
}

export const saveSeries = async (series: Series) => {
  await seriesStorage().setItem(series.id, series)
  return series
}

export const removeSeries = async (id: SeriesId) => {
  await seriesStorage().removeItem(id)
}

export const findAllSeriesBooks = async () => {
  const keys = await seriesBooksStorage().getKeys()
  const items = await seriesBooksStorage().getItems<SeriesBook>(keys)
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
