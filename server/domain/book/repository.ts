import type { Book, BookId } from '~/domain/book/types'

const storage = () => useStorage('books')
const imageStorage = () => useStorage('book-images')

export const findAll = async () => {
  const keys = await storage().getKeys()
  const items = await storage().getItems<Book>(keys)
  return items.map(({ value }) => value)
}

export const findBy = (id: BookId) => storage().getItem<Book>(id)

export const findImageBy = (id: BookId) => imageStorage().getItem<string>(id)

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
