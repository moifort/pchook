import type { BookId } from '~/domain/book/types'
import type { Review } from '~/domain/review/types'
import { createTypedStorage } from '~/system/storage'

const storage = () => createTypedStorage<Review>('reviews')

export const findAll = async () => {
  const keys = await storage().getKeys()
  const items = await storage().getItems(keys)
  return items.map(({ value }) => value)
}

export const findBy = (bookId: BookId) => storage().getItem(`entries:${bookId}`)

export const save = async (review: Review) => {
  await storage().setItem(`entries:${review.bookId}`, review)
  return review
}

export const remove = async (bookId: BookId) => {
  await storage().removeItem(`entries:${bookId}`)
}
