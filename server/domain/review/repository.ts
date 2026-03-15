import type { BookId } from '~/domain/book/types'
import type { Review } from '~/domain/review/types'

const storage = () => useStorage('reviews')

export const findAll = async () => {
  const keys = await storage().getKeys()
  const items = await storage().getItems<Review>(keys)
  return items.map(({ value }) => value)
}

export const findBy = (bookId: BookId) => storage().getItem<Review>(`entries:${bookId}`)

export const save = async (review: Review) => {
  await storage().setItem(`entries:${review.bookId}`, review)
  return review
}

export const remove = async (bookId: BookId) => {
  await storage().removeItem(`entries:${bookId}`)
}
