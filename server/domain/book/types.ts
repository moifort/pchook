import type { Brand } from 'ts-brand'
import type { Eur, PersonName, Url } from '~/domain/shared/types'

export type BookId = Brand<string, 'BookId'>
export type BookTitle = Brand<string, 'BookTitle'>
export type Publisher = Brand<string, 'Publisher'>
export type Genre = Brand<string, 'Genre'>
export type ISBN = Brand<string, 'ISBN'>
export type Language = Brand<string, 'Language'>
export type PageCount = Brand<number, 'PageCount'>
export type Note = Brand<number, 'Note'>

export type BookFormat = 'pocket' | 'paperback' | 'hardcover' | 'audiobook'
export type BookStatus = 'to-read' | 'read'
export type ImportSource = 'scan' | 'isbn' | 'url' | 'audible'
export type BookSort = 'createdAt' | 'title' | 'author' | 'awards' | 'genre'
export type SortOrder = 'asc' | 'desc'

export type Award = {
  name: string
  year?: number
}

export type Book = {
  id: BookId
  title: BookTitle
  authors: PersonName[]
  publisher?: Publisher
  publishedDate?: Date
  pageCount?: PageCount
  genre?: Genre
  synopsis?: string
  isbn?: ISBN
  language?: Language
  format?: BookFormat
  translator?: PersonName
  estimatedPrice?: Eur
  duration?: string
  narrators: PersonName[]
  personalNotes?: string
  status: BookStatus
  readDate?: Date
  awards: Award[]
  importSource?: ImportSource
  externalUrl?: Url
  createdAt: Date
  updatedAt: Date
}
