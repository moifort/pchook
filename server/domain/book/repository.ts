import type { Book, BookId, ISBN } from '~/domain/book/types'
import { createTypedStorage } from '~/system/storage'

const storage = () => createTypedStorage<Book>('books')
const imageStorage = () => useStorage('book-images')

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
    const bookAuthors = book.authors.map((a) => normalizeForMatch(String(a))).sort()
    if (bookAuthors.length !== normalizedAuthors.length) return false
    if (!bookAuthors.every((a, i) => a === normalizedAuthors[i])) return false
    const bookTitle = normalizeForMatch(String(book.title))
    const bookCore = normalizeForMatch(coreTitle(String(book.title)))
    return bookTitle === normalizedTitle || bookCore === normalizedCore
  })
}

export const findImageBy = async (id: BookId) =>
  (await imageStorage().getItem<string>(id)) ?? undefined

export const save = async (book: Book) => {
  await storage().setItem(book.id, book)
  return book
}

export const saveImage = async (id: BookId, imageBase64: string) => {
  await imageStorage().setItem(id, imageBase64)
}

export const remove = async (id: BookId) => {
  await storage().removeItem(id)
  await imageStorage().removeItem(id)
}
