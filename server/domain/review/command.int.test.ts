import { describe, expect, test } from 'bun:test'
import { Note, randomBookId } from '~/domain/book/primitives'
import { ReviewCommand } from '~/domain/review/command'
import { ReviewQuery } from '~/domain/review/query'
import type { Review } from '~/domain/review/types'

const buildReview = (overrides?: Partial<Review>): Review => ({
  bookId: randomBookId(),
  rating: Note(4),
  createdAt: new Date(),
  ...overrides,
})

describe('ReviewCommand.create', () => {
  test('creates and returns the review', async () => {
    const review = buildReview()

    const result = await ReviewCommand.create(review)

    expect(result).toEqual(review)
  })

  test('persists the review so it can be queried by book id', async () => {
    const review = buildReview()

    await ReviewCommand.create(review)

    const found = await ReviewQuery.getByBookId(review.bookId)
    expect(found).toEqual(review)
  })

  test('preserves optional fields', async () => {
    const review = buildReview({
      readDate: new Date('2025-06-15'),
      reviewNotes: 'A compelling narrative with rich characters.',
    })

    await ReviewCommand.create(review)

    const found = await ReviewQuery.getByBookId(review.bookId)
    expect(found).toEqual(review)
  })
})

describe('ReviewCommand.removeBook', () => {
  test('removes the review for a book', async () => {
    const review = buildReview()
    await ReviewCommand.create(review)

    await ReviewCommand.removeBook(review.bookId)

    const result = await ReviewQuery.getByBookId(review.bookId)
    expect(result).toBe('not-found')
  })

  test('does not affect other reviews', async () => {
    const reviewA = buildReview()
    const reviewB = buildReview()
    await ReviewCommand.create(reviewA)
    await ReviewCommand.create(reviewB)

    await ReviewCommand.removeBook(reviewA.bookId)

    expect(await ReviewQuery.getByBookId(reviewA.bookId)).toBe('not-found')
    expect(await ReviewQuery.getByBookId(reviewB.bookId)).toEqual(reviewB)
  })

  test('does nothing when removing a non-existent review', async () => {
    const bookId = randomBookId()

    await ReviewCommand.removeBook(bookId)

    expect(await ReviewQuery.getByBookId(bookId)).toBe('not-found')
  })
})
