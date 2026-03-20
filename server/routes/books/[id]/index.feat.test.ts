import { expect } from 'bun:test'
import { BookCommand } from '~/domain/book/command'
import { BookTitle, Genre, Note } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import type { BookId } from '~/domain/book/types'
import { ReviewCommand } from '~/domain/review/command'
import { ReviewQuery } from '~/domain/review/query'
import { SeriesCommand } from '~/domain/series/command'
import { SeriesLabel, SeriesPosition } from '~/domain/series/primitives'
import { SeriesQuery } from '~/domain/series/query'
import deleteHandler from '~/routes/books/[id]/index.delete'
import getHandler from '~/routes/books/[id]/index.get'
import { and, feature, given, scenario, then, when } from '~/test/bdd'
import { mockEvent } from '~/test/setup'

feature('DELETE /books/[id]', () => {
  scenario('deletes a book and cascades to review and series', async () => {
    given('a book exists with a review and a series entry')
    const book = await BookCommand.add(BookTitle('Germinal'), {
      genre: Genre('Roman naturaliste'),
      status: 'read',
    })
    const bookId = book.id as BookId
    await ReviewCommand.create({
      bookId,
      rating: Note(4),
      createdAt: new Date(),
    })
    const series = await SeriesCommand.findOrCreate('Les Rougon-Macquart')
    await SeriesCommand.addBook(series.id, bookId, SeriesLabel('13'), SeriesPosition(13))

    when('DELETE /books/[id] is called')
    const event = mockEvent({ params: { id: String(bookId) } })
    const result = await deleteHandler(event as never)

    then('the response confirms deletion')
    expect(result.status).toBe(200)
    expect(result.data).toBeNull()

    and('the book no longer exists')
    const bookResult = await BookQuery.getById(bookId)
    expect(bookResult).toBe('not-found')

    and('the review is removed')
    const reviewResult = await ReviewQuery.getByBookId(bookId)
    expect(reviewResult).toBe('not-found')

    and('the series entry is removed')
    const seriesResult = await SeriesQuery.getByBookId(bookId)
    expect(seriesResult).toBeNull()
  })

  scenario('returns 404 for a non-existent book', async () => {
    given('no book exists with this ID')
    const fakeId = crypto.randomUUID()

    when('DELETE /books/[id] is called with a non-existent ID')
    const event = mockEvent({ params: { id: fakeId } })

    then('a 404 error is thrown')
    expect(deleteHandler(event as never)).rejects.toMatchObject({ statusCode: 404 })
  })
})

feature('GET /books/[id]', () => {
  scenario('returns book detail with series and review', async () => {
    given('a book exists with a review and a series entry')
    const book = await BookCommand.add(BookTitle('Le Petit Prince'), {
      genre: Genre('Conte'),
      status: 'read',
    })
    const bookId = book.id as BookId
    await ReviewCommand.create({
      bookId,
      rating: Note(5),
      createdAt: new Date(),
    })
    const series = await SeriesCommand.findOrCreate('Classiques')
    await SeriesCommand.addBook(series.id, bookId, SeriesLabel('1'), SeriesPosition(1))

    when('GET /books/[id] is called')
    const event = mockEvent({ params: { id: String(bookId) } })
    const result = await getHandler(event as never)

    then('the response contains the book')
    expect(result.status).toBe(200)
    expect(String(result.data.book.title)).toBe('Le Petit Prince')

    and('the series info is included')
    expect(result.data.series).toBeDefined()
    expect(result.data.series?.name).toBe('Classiques')
    expect(result.data.series?.label).toBe('1')
    expect(result.data.series?.position).toBe(1)

    and('the review is included')
    expect(result.data.review).toBeDefined()
    expect(Number(result.data.review?.rating)).toBe(5)
  })

  scenario('returns 404 for a non-existent book', async () => {
    given('no book exists with this ID')
    const fakeId = crypto.randomUUID()

    when('GET /books/[id] is called with a non-existent ID')
    const event = mockEvent({ params: { id: fakeId } })

    then('a 404 error is thrown')
    expect(getHandler(event as never)).rejects.toMatchObject({ statusCode: 404 })
  })
})
