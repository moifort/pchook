import type { Brand } from 'ts-brand'
import type { BookId } from '~/domain/book/types'

export type SeriesId = Brand<string, 'SeriesId'>
export type SeriesName = Brand<string, 'SeriesName'>
export type Position = Brand<number, 'Position'>

export type Series = {
  id: SeriesId
  name: SeriesName
  createdAt: Date
}

export type SeriesBook = {
  seriesId: SeriesId
  bookId: BookId
  position: Position
  addedAt: Date
}
