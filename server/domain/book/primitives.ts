import { make } from 'ts-brand'
import { z } from 'zod'
import type {
  BookFormat as BookFormatType,
  BookId as BookIdType,
  BookSort as BookSortType,
  BookStatus as BookStatusType,
  BookTitle as BookTitleType,
  Genre as GenreType,
  ISBN as ISBNType,
  Language as LanguageType,
  Note as NoteType,
  PageCount as PageCountType,
  Publisher as PublisherType,
  SortOrder as SortOrderType,
} from '~/domain/book/types'

export const BookId = (value: unknown) => {
  const v = z.string().uuid().parse(value)
  return make<BookIdType>()(v)
}

export const randomBookId = () => BookId(crypto.randomUUID())

export const BookTitle = (value: unknown) => {
  const v = z.string().min(1).parse(value)
  return make<BookTitleType>()(v)
}

export const Publisher = (value: unknown) => {
  const v = z.string().min(1).parse(value)
  return make<PublisherType>()(v)
}

export const Genre = (value: unknown) => {
  const v = z.string().min(1).parse(value)
  return make<GenreType>()(v)
}

export const ISBN = (value: unknown) => {
  const v = z.string().min(10).max(17).parse(value)
  return make<ISBNType>()(v)
}

export const Language = (value: unknown) => {
  const v = z.string().min(1).parse(value)
  return make<LanguageType>()(v)
}

export const PageCount = (value: unknown) => {
  const v = z
    .preprocess((v) => (typeof v === 'string' ? Number(v) : v), z.number().int().positive())
    .parse(value)
  return make<PageCountType>()(v)
}

export const Note = (value: unknown) => {
  const v = z
    .preprocess((v) => {
      const n = typeof v === 'string' ? Number(v) : v
      return typeof n === 'number' ? Math.round(n) : n
    }, z.number().int().min(0).max(10))
    .parse(value)
  return make<NoteType>()(v)
}

export const BookFormat = (value: unknown) =>
  z.enum(['pocket', 'paperback', 'hardcover', 'audiobook']).parse(value) as BookFormatType

export const BookStatus = (value: unknown) =>
  z.enum(['to-read', 'read']).parse(value) as BookStatusType

export const BookSort = (value: unknown) =>
  z.enum(['createdAt', 'title', 'author', 'awards', 'genre']).parse(value) as BookSortType

export const SortOrder = (value: unknown) => z.enum(['asc', 'desc']).parse(value) as SortOrderType
