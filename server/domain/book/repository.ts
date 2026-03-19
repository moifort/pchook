import type { Book, BookId, ISBN } from '~/domain/book/types'

const storage = () => useStorage('books')
const imageStorage = () => useStorage('book-images')

export const findAll = async () => {
  const keys = await storage().getKeys()
  const items = await storage().getItems<Book>(keys)
  return items.map(({ value }) => value)
}

export const findBy = (id: BookId) => storage().getItem<Book>(id)

export const findByISBN = async (isbn: ISBN) => {
  const books = await findAll()
  return books.find((book) => book.isbn === isbn)
}

export const findByTitleAndAuthors = async (title: string, authors: string[]) => {
  const normalize = (s: string) => s.toLowerCase().trim()
  const normalizedTitle = normalize(title)
  const normalizedAuthors = authors.map(normalize).sort()
  const books = await findAll()
  return books.find((book) => {
    const bookAuthors = book.authors.map((a) => normalize(String(a))).sort()
    return (
      normalize(String(book.title)) === normalizedTitle &&
      bookAuthors.length === normalizedAuthors.length &&
      bookAuthors.every((a, i) => a === normalizedAuthors[i])
    )
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
