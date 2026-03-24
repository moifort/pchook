import { expect } from 'bun:test'
import { graphql } from 'graphql'
import { BookCommand } from '~/domain/book/command'
import { BookTitle, Genre, Note } from '~/domain/book/primitives'
import { ReviewCommand } from '~/domain/review/command'
import type { Review } from '~/domain/review/types'
import { SeriesCommand } from '~/domain/series/command'
import { SeriesLabel, SeriesPosition } from '~/domain/series/primitives'
import { schema } from '~/domain/shared/graphql/schema'
import { and, feature, given, scenario, then, when } from '~/test/bdd'

const execute = (query: string, variables?: Record<string, unknown>) =>
  graphql({ schema, source: query, variableValues: variables, contextValue: {} })

feature('GraphQL query: books', () => {
  scenario('lists all books', async () => {
    given('several books exist')
    await BookCommand.add(BookTitle('Germinal'), { genre: Genre('Roman naturaliste') })
    await BookCommand.add(BookTitle('Le Petit Prince'), { genre: Genre('Conte') })
    await BookCommand.add(BookTitle('Les Fleurs du Mal'), { genre: Genre('Poésie') })

    when('books query is called without filters')
    const result = await execute('{ books { id title genre } }')

    then('all books are returned')
    expect(result.errors).toBeUndefined()
    expect(result.data?.books).toHaveLength(3)
  })

  scenario('filters books by status', async () => {
    given('books with different statuses exist')
    await BookCommand.add(BookTitle('Germinal'), { status: 'to-read' })
    await BookCommand.add(BookTitle('Le Petit Prince'), { status: 'read' })
    await BookCommand.add(BookTitle('Les Fleurs du Mal'), { status: 'to-read' })

    when('books query is called with status filter')
    const result = await execute('{ books(status: "to-read") { id title status } }')

    then('only to-read books are returned')
    expect(result.errors).toBeUndefined()
    expect(result.data?.books).toHaveLength(2)
    and('all returned books have status TO_READ')
    const books = result.data?.books as { status: string }[]
    expect(books.every(({ status }) => status === 'TO_READ')).toBe(true)
  })

  scenario('sorts books by title ascending', async () => {
    given('several books exist')
    await BookCommand.add(BookTitle('Germinal'), {})
    await BookCommand.add(BookTitle('Les Fleurs du Mal'), {})
    await BookCommand.add(BookTitle('Anna Karénine'), {})

    when('books query is called with sort and order')
    const result = await execute('{ books(sort: title, order: asc) { title } }')

    then('books are sorted alphabetically')
    expect(result.errors).toBeUndefined()
    const books = result.data?.books as { title: string }[]
    expect(books[0].title).toBe('Anna Karénine')
    expect(books[2].title).toBe('Les Fleurs du Mal')
  })
})

feature('GraphQL query: book', () => {
  scenario('returns book detail with review and series', async () => {
    given('a book exists with a review and series')
    const book = await BookCommand.add(BookTitle('Germinal'), {
      genre: Genre('Roman naturaliste'),
    })
    const review: Review = {
      bookId: book.id,
      rating: Note(8),
      readDate: new Date('2024-01-15'),
      reviewNotes: 'Excellent roman social',
      createdAt: new Date(),
    }
    await ReviewCommand.create(review)
    const series = await SeriesCommand.findOrCreate('Les Rougon-Macquart')
    await SeriesCommand.addBook(series.id, book.id, SeriesLabel('Tome 13'), SeriesPosition(13))

    when('book query is called with nested fields')
    const result = await execute(`{
      book(id: "${String(book.id)}") {
        title
        genre
        review { rating readDate reviewNotes }
        series { name label position books { title } }
      }
    }`)

    then('book detail is returned with all nested data')
    expect(result.errors).toBeUndefined()
    const data = result.data?.book as Record<string, unknown>
    expect(data.title).toBe('Germinal')
    expect(data.genre).toBe('Roman naturaliste')

    and('review is included')
    const reviewData = data.review as Record<string, unknown>
    expect(reviewData.rating).toBe(8)
    expect(reviewData.reviewNotes).toBe('Excellent roman social')

    and('series is included')
    const seriesData = data.series as Record<string, unknown>
    expect(seriesData.name).toBe('Les Rougon-Macquart')
    expect(seriesData.label).toBe('Tome 13')
    expect(seriesData.position).toBe(13)
  })

  scenario('returns null for non-existent book', async () => {
    when('book query is called with non-existent id')
    const result = await execute(`{
      book(id: "00000000-0000-0000-0000-000000000000") { title }
    }`)

    then('null is returned without errors')
    expect(result.errors).toBeUndefined()
    expect(result.data?.book).toBeNull()
  })

  scenario('allows requesting only specific fields', async () => {
    given('a book exists')
    const book = await BookCommand.add(BookTitle('Le Petit Prince'), {})

    when('book query requests only title')
    const result = await execute(`{
      book(id: "${String(book.id)}") { title }
    }`)

    then('only the requested field is returned')
    expect(result.errors).toBeUndefined()
    const data = result.data?.book as Record<string, unknown>
    expect(data.title).toBe('Le Petit Prince')
    expect(data).not.toHaveProperty('genre')
  })
})
