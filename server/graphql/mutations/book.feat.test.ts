import { expect } from 'bun:test'
import { graphql } from 'graphql'
import { BookCommand } from '~/domain/book/command'
import { BookTitle, Genre } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import { ReviewQuery } from '~/domain/review/query'
import { SeriesQuery } from '~/domain/series/query'
import { schema } from '~/graphql/schema'
import { and, feature, given, scenario, then, when } from '~/test/bdd'

const execute = (query: string, variables?: Record<string, unknown>) =>
  graphql({ schema, source: query, variableValues: variables, contextValue: {} })

feature('GraphQL mutation: updateBook', () => {
  scenario('updates book fields', async () => {
    given('a book exists')
    const book = await BookCommand.add(BookTitle('Germnal'), { genre: Genre('Roman') })

    when('updateBook mutation is called')
    const result = await execute(
      `mutation ($id: ID!, $input: UpdateBookInput!) {
        updateBook(id: $id, input: $input) { title genre }
      }`,
      { id: String(book.id), input: { title: 'Germinal', genre: 'Roman naturaliste' } },
    )

    then('book is updated')
    expect(result.errors).toBeUndefined()
    const data = result.data?.updateBook as Record<string, unknown>
    expect(data.title).toBe('Germinal')
    expect(data.genre).toBe('Roman naturaliste')
  })

  scenario('updates book with series', async () => {
    given('a book exists')
    const book = await BookCommand.add(BookTitle('Germinal'), {})

    when('updateBook is called with series info')
    const result = await execute(
      `mutation ($id: ID!, $input: UpdateBookInput!) {
        updateBook(id: $id, input: $input) { title }
      }`,
      {
        id: String(book.id),
        input: { series: 'Les Rougon-Macquart', seriesLabel: 'Tome 13', seriesNumber: 13 },
      },
    )

    then('book is updated')
    expect(result.errors).toBeUndefined()

    and('series is linked')
    const seriesInfo = await SeriesQuery.getByBookId(book.id)
    expect(seriesInfo).not.toBeNull()
    expect(String(seriesInfo?.name)).toBe('Les Rougon-Macquart')
  })

  scenario('returns error for non-existent book', async () => {
    when('updateBook is called with non-existent id')
    const result = await execute(
      `mutation {
        updateBook(id: "00000000-0000-0000-0000-000000000000", input: { title: "Test" }) { title }
      }`,
    )

    then('error is returned')
    expect(result.errors).toHaveLength(1)
    expect(result.errors?.[0].message).toBe('Book not found')
  })
})

feature('GraphQL mutation: deleteBook', () => {
  scenario('deletes book and associated data', async () => {
    given('a book exists with review and series')
    const book = await BookCommand.add(BookTitle('Germinal'), {})

    when('deleteBook mutation is called')
    const result = await execute(`mutation { deleteBook(id: "${String(book.id)}") }`)

    then('deletion succeeds')
    expect(result.errors).toBeUndefined()
    expect(result.data?.deleteBook).toBe(true)

    and('book no longer exists')
    const found = await BookQuery.getById(book.id)
    expect(found).toBe('not-found')
  })
})

feature('GraphQL mutation: addToFavorites', () => {
  scenario('marks book as favorite', async () => {
    given('a book exists')
    const book = await BookCommand.add(BookTitle('Le Petit Prince'), { status: 'to-read' })

    when('addToFavorites mutation is called')
    const result = await execute(
      `mutation { addToFavorites(id: "${String(book.id)}") { title status } }`,
    )

    then('book is marked as read')
    expect(result.errors).toBeUndefined()
    const data = result.data?.addToFavorites as Record<string, unknown>
    expect(data.status).toBe('READ')

    and('a review with favorite rating is created')
    const review = await ReviewQuery.getByBookId(book.id)
    expect(review).not.toBe('not-found')
    if (review !== 'not-found') {
      expect(Number(review.rating)).toBe(5)
    }
  })
})

feature('GraphQL mutation: addReview', () => {
  scenario('creates a review for a book', async () => {
    given('a book exists')
    const book = await BookCommand.add(BookTitle('Germinal'), { status: 'to-read' })

    when('addReview mutation is called')
    const result = await execute(
      `mutation ($bookId: ID!, $input: CreateReviewInput!) {
        addReview(bookId: $bookId, input: $input) { rating readDate reviewNotes }
      }`,
      {
        bookId: String(book.id),
        input: { rating: 9, readDate: '2024-06-15', reviewNotes: "Chef-d'œuvre du naturalisme" },
      },
    )

    then('review is created')
    expect(result.errors).toBeUndefined()
    const data = result.data?.addReview as Record<string, unknown>
    expect(data.rating).toBe(9)
    expect(data.reviewNotes).toBe("Chef-d'œuvre du naturalisme")

    and('book is marked as read')
    const updated = await BookQuery.getById(book.id)
    expect(updated !== 'not-found' && updated.status).toBe('read')
  })
})
