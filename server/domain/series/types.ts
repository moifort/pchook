import type { Brand } from 'ts-brand'
import type { BookId } from '~/domain/book/types'

export type SeriesId = Brand<string, 'SeriesId'>
export type SeriesName = Brand<string, 'SeriesName'>
export type SeriesLabel = Brand<string, 'SeriesLabel'>
export type SeriesPosition = Brand<number, 'SeriesPosition'>

export type Series = {
  id: SeriesId
  name: SeriesName
  createdAt: Date
}

export type SeriesBook = {
  seriesId: SeriesId
  bookId: BookId
  label: SeriesLabel
  position: SeriesPosition
  addedAt: Date
}
