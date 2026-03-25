import type { Book, BookId, ISBN } from '~/domain/book/types'
import { createTypedStorage } from '~/system/storage'

const storage = () => createTypedStorage<Book>('books')

export const findAll = async () => {
  const keys = await storage().getKeys()
  const items = await storage().getItems(keys)
  return items.map(({ value }) => value)
}

export const findBy = (id: BookId) => storage().getItem(id)

export const findByISBN = async (isbn: ISBN) => {
  const books = await findAll()
  return books.find((book) => book.isbn === isbn)
}

const normalizeForMatch = (s: string) => s.toLowerCase().trim()

const coreTitle = (title: string) =>
  title
    .split(/[.:]/)[0]
    .trim()
    .replace(/[''""«»]/g, '')
    .replace(/\s+/g, ' ')

export const findByTitleAndAuthors = async (title: string, authors: string[]) => {
  const normalizedTitle = normalizeForMatch(title)
  const normalizedCore = normalizeForMatch(coreTitle(title))
  const normalizedAuthors = authors.map(normalizeForMatch).sort()
  const books = await findAll()
  return books.find((book) => {
    const bookAuthors = book.authors.map((a) => normalizeForMatch(a)).sort()
    if (bookAuthors.length !== normalizedAuthors.length) return false
    if (!bookAuthors.every((a, i) => a === normalizedAuthors[i])) return false
    const bookTitle = normalizeForMatch(book.title)
    const bookCore = normalizeForMatch(coreTitle(book.title))
    return bookTitle === normalizedTitle || bookCore === normalizedCore
  })
}

export const save = async (book: Book) => {
  await storage().setItem(book.id, book)
  return book
}

export const remove = async (id: BookId) => {
  await storage().removeItem(id)
}
