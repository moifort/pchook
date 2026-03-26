import { uniq } from 'lodash-es'
import { BookQuery } from '~/domain/book/query'
import type { Book, BookId, Language } from '~/domain/book/types'
import * as index from '~/domain/search/index'
import type {
  AuthorSearchResult,
  BookSearchResult,
  SeriesSearchResult,
} from '~/domain/search/types'
import { SeriesQuery } from '~/domain/series/query'
import { createLogger } from '~/system/logger'

const log = createLogger('search')

export namespace SearchCommand {
  export const indexBookById = async (bookId: BookId) => {
    const book = await BookQuery.getById(bookId)
    if (book === 'not-found') return
    indexBookEntity(book)
  }

  export const removeBook = (bookId: BookId) => {
    index.removeBook(bookId)
  }

  export const rebuildAll = async () => {
    index.clearAll()

    const [allBooks, allSeries] = await Promise.all([BookQuery.findAll(), SeriesQuery.findAll()])

    allBooks.forEach((book) => {
      indexBookEntity(book)
    })

    await Promise.all(
      allSeries.map(async (series) => {
        const detail = await SeriesQuery.getById(series.id)
        const books = detail === 'not-found' ? [] : detail.books
        const result: SeriesSearchResult = {
          id: series.id,
          name: series.name,
          volumeCount: books.length,
          rating: series.rating,
          languages: uniq(
            books
              .map(({ language }) => language)
              .filter((language): language is Language => !!language),
          ),
        }
        index.indexSeries(result)
      }),
    )

    const authorMap = new Map<string, { bookCount: number; firstBookId: BookId }>()
    allBooks.forEach((book) => {
      book.authors.forEach((author) => {
        const existing = authorMap.get(author)
        if (existing) {
          existing.bookCount++
        } else {
          authorMap.set(author, { bookCount: 1, firstBookId: book.id })
        }
      })
    })

    authorMap.forEach(({ bookCount, firstBookId }, name) => {
      const result: AuthorSearchResult = { name, bookCount, firstBookId }
      index.indexAuthor(result)
    })

    log.info('Search index rebuilt', {
      books: allBooks.length,
      series: allSeries.length,
      authors: authorMap.size,
    })
  }

  export const rebuildAuthors = async () => {
    const allBooks = await BookQuery.findAll()
    const authorMap = new Map<string, { bookCount: number; firstBookId: BookId }>()
    allBooks.forEach((book) => {
      book.authors.forEach((author) => {
        const existing = authorMap.get(author)
        if (existing) {
          existing.bookCount++
        } else {
          authorMap.set(author, { bookCount: 1, firstBookId: book.id })
        }
      })
    })
    authorMap.forEach(({ bookCount, firstBookId }, name) => {
      index.indexAuthor({ name, bookCount, firstBookId })
    })
  }

  export const rebuildSeries = async () => {
    const allSeries = await SeriesQuery.findAll()
    await Promise.all(
      allSeries.map(async (series) => {
        const detail = await SeriesQuery.getById(series.id)
        const books = detail === 'not-found' ? [] : detail.books
        index.indexSeries({
          id: series.id,
          name: series.name,
          volumeCount: books.length,
          rating: series.rating,
          languages: uniq(
            books
              .map(({ language }) => language)
              .filter((language): language is Language => !!language),
          ),
        })
      }),
    )
  }
}

const indexBookEntity = (book: Book) => {
  const result: BookSearchResult = {
    id: book.id,
    title: book.title,
    authors: [...book.authors],
    language: book.language,
    status: book.status,
    coverImageId: book.coverImageId,
  }
  index.indexBook(result)
}
