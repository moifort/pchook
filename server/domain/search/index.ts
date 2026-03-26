import { normalize } from '~/domain/search/business-rules'
import type {
  AuthorSearchResult,
  BookSearchResult,
  SearchEntry,
  SeriesSearchResult,
} from '~/domain/search/types'

const entries: SearchEntry[] = []
const bookResults = new Map<string, BookSearchResult>()
const seriesResults = new Map<string, SeriesSearchResult>()
const authorResults = new Map<string, AuthorSearchResult>()

export const getEntries = () => entries

export const getBookResult = (id: string) => bookResults.get(id)
export const getSeriesResult = (id: string) => seriesResults.get(id)
export const getAuthorResult = (name: string) => authorResults.get(name)

const addEntry = (type: SearchEntry['type'], entityId: string, text: string) => {
  entries.push({ type, entityId, text, normalizedText: normalize(text) })
}

export const indexBook = (book: BookSearchResult) => {
  removeByEntityId('book', book.id)
  bookResults.set(book.id, book)
  addEntry('book', book.id, book.title)
  book.authors.forEach((author) => {
    addEntry('book', book.id, author)
  })
}

export const indexSeries = (series: SeriesSearchResult) => {
  removeByEntityId('series', series.id)
  seriesResults.set(series.id, series)
  addEntry('series', series.id, series.name)
}

export const indexAuthor = (author: AuthorSearchResult) => {
  removeByEntityId('author', author.name)
  authorResults.set(author.name, author)
  addEntry('author', author.name, author.name)
}

export const removeByEntityId = (type: SearchEntry['type'], entityId: string) => {
  let i = entries.length
  while (i--) {
    if (entries[i].type === type && entries[i].entityId === entityId) entries.splice(i, 1)
  }
}

export const removeBook = (bookId: string) => {
  removeByEntityId('book', bookId)
  bookResults.delete(bookId)
}

export const clearAll = () => {
  entries.length = 0
  bookResults.clear()
  seriesResults.clear()
  authorResults.clear()
}
