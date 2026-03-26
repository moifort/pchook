import { make } from 'ts-brand'
import { z } from 'zod'
import type {
  BookFormat as BookFormatType,
  BookId as BookIdType,
  BookSort as BookSortType,
  BookStatus as BookStatusType,
  BookTitle as BookTitleType,
  Genre as GenreType,
  ImportSource as ImportSourceType,
  ISBN as ISBNType,
  Note as NoteType,
  PageCount as PageCountType,
  Publisher as PublisherType,
  RatingScore as RatingScoreType,
  SortOrder as SortOrderType,
} from '~/domain/book/types'
import { type Language as LanguageType, languageValues } from '~/domain/book/types'

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

const languageNameToCode: Record<string, string> = {
  french: 'fr',
  english: 'en',
  spanish: 'es',
  german: 'de',
  italian: 'it',
  portuguese: 'pt',
  japanese: 'ja',
  chinese: 'zh',
  korean: 'ko',
  russian: 'ru',
  dutch: 'nl',
  polish: 'pl',
  swedish: 'sv',
  arabic: 'ar',
  czech: 'cs',
  danish: 'da',
  finnish: 'fi',
  greek: 'el',
  hungarian: 'hu',
  norwegian: 'no',
  romanian: 'ro',
  turkish: 'tr',
  ukrainian: 'uk',
  hebrew: 'he',
  hindi: 'hi',
  thai: 'th',
  vietnamese: 'vi',
  indonesian: 'id',
  catalan: 'ca',
  latin: 'la',
}

export const Language = (value: unknown) => {
  const normalized = z
    .string()
    .min(1)
    .transform((v) => {
      const lower = v.toLowerCase()
      return languageNameToCode[lower] ?? lower
    })
    .parse(value)
  return z.enum(languageValues).parse(normalized) as LanguageType
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
    }, z.number().int().min(0).max(5))
    .parse(value)
  return make<NoteType>()(v)
}

export const RatingScore = (value: unknown) => {
  const v = z
    .preprocess((v) => (typeof v === 'string' ? Number(v) : v), z.number().min(0).max(10))
    .parse(value)
  return make<RatingScoreType>()(v)
}

export const BookFormat = (value: unknown) =>
  z
    .enum(['pocket', 'paperback', 'hardcover', 'audiobook', 'digital'])
    .parse(value) as BookFormatType

export const BookStatus = (value: unknown) =>
  z.enum(['to-read', 'read']).parse(value) as BookStatusType

export const BookSort = (value: unknown) =>
  z
    .enum(['createdAt', 'title', 'author', 'awards', 'genre', 'publishedDate'])
    .parse(value) as BookSortType

export const ImportSource = (value: unknown) =>
  z.enum(['scan', 'isbn', 'url', 'audible']).parse(value) as ImportSourceType

export const SortOrder = (value: unknown) => z.enum(['asc', 'desc']).parse(value) as SortOrderType
