import DataLoader from 'dataloader'
import { keyBy, uniq } from 'lodash-es'
import type { BookId } from '~/domain/book/types'
import * as reviewRepository from '~/domain/review/infrastructure/repository'
import * as seriesRepository from '~/domain/series/infrastructure/repository'
import type { Series, SeriesBook } from '~/domain/series/types'

export type SeriesBookEntry = Series & Pick<SeriesBook, 'label' | 'position'>

export const createLoaders = () => ({
  review: new DataLoader<string, Awaited<ReturnType<typeof reviewRepository.findBy>>>(
    async (bookIds) => {
      const reviews = await Promise.all(
        bookIds.map((bookId) => reviewRepository.findBy(bookId as BookId)),
      )
      return reviews
    },
  ),

  seriesBook: new DataLoader<string, SeriesBookEntry | null>(async (bookIds) => {
    const allSeriesBooks = await seriesRepository.findAllSeriesBooks()
    const seriesBookByBookId = keyBy(allSeriesBooks, ({ bookId }) => bookId)

    const matchedEntries = bookIds.map((bookId) => seriesBookByBookId[bookId]).filter(Boolean)
    const uniqueSeriesIds = uniq(matchedEntries.map(({ seriesId }) => seriesId))

    const seriesList = await Promise.all(
      uniqueSeriesIds.map((id) => seriesRepository.findSeriesBy(id)),
    )
    const seriesById = keyBy(
      seriesList.filter((s): s is Series => s !== null),
      ({ id }) => id,
    )

    return bookIds.map((bookId) => {
      const entry = seriesBookByBookId[bookId]
      if (!entry) return null
      const series = seriesById[entry.seriesId]
      if (!series) return null
      return { ...series, label: entry.label, position: entry.position }
    })
  }),
})

export type Loaders = ReturnType<typeof createLoaders>
