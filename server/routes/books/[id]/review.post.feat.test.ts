import { expect } from 'bun:test'
import { BookCommand } from '~/domain/book/command'
import { BookTitle, Note, randomBookId } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import reviewHandler from '~/routes/books/[id]/review.post'
import { and, feature, given, scenario, then, when } from '~/test/bdd'
import { mockEvent } from '~/test/setup'

feature('POST /books/[id]/review', () => {
  scenario('creates a review for an existing book', async () => {
    given('a book exists')
    const book = await BookCommand.add(BookTitle('Test Book'), {})

    when('a review is submitted with rating, readDate and reviewNotes')
    const event = mockEvent({
      params: { id: String(book.id) },
      body: { rating: 8, readDate: '2025-01-15', reviewNotes: 'Great book' },
    })
    const result = await reviewHandler(event as never)

    then('the review is created with status 201')
    expect(result.status).toBe(201)
    expect(result.data.rating).toBe(Note(8))
    expect(result.data.readDate).toEqual(new Date('2025-01-15'))
    expect(result.data.reviewNotes).toBe('Great book')

    and('the book status is changed to read')
    const updated = await BookQuery.getById(book.id)
    expect(updated).not.toBe('not-found')
    if (updated === 'not-found') return
    expect(updated.status).toBe('read')
  })

  scenario('creates a review with minimal data (only rating)', async () => {
    given('a book exists')
    const book = await BookCommand.add(BookTitle('Minimal Review Book'), {})

    when('a review is submitted with only a rating')
    const event = mockEvent({
      params: { id: String(book.id) },
      body: { rating: 5 },
    })
    const result = await reviewHandler(event as never)

    then('the review is created with status 201')
    expect(result.status).toBe(201)
    expect(result.data.rating).toBe(Note(5))
    expect(result.data.readDate).toBeUndefined()
    expect(result.data.reviewNotes).toBeUndefined()

    and('the book status is changed to read')
    const updated = await BookQuery.getById(book.id)
    expect(updated).not.toBe('not-found')
    if (updated === 'not-found') return
    expect(updated.status).toBe('read')
  })

  scenario('returns 404 when book does not exist', async () => {
    given('no book exists with the given id')
    const id = randomBookId()

    when('a review is submitted for a non-existent book')
    const event = mockEvent({
      params: { id: String(id) },
      body: { rating: 7 },
    })

    then('a 404 error is thrown')
    await expect(reviewHandler(event as never)).rejects.toMatchObject({ statusCode: 404 })
  })
})
