import { expect } from 'bun:test'
import { graphql } from 'graphql'
import { BookCommand } from '~/domain/book/command'
import { BookTitle, Genre, Note } from '~/domain/book/primitives'
import { ReviewCommand } from '~/domain/review/command'
import type { Review } from '~/domain/review/types'
import { SeriesCommand } from '~/domain/series/command'
import { SeriesLabel, SeriesPosition } from '~/domain/series/primitives'
import { createLoaders } from '~/domain/shared/graphql/loaders'
import { schema } from '~/domain/shared/graphql/schema'
import { and, feature, given, scenario, then, when } from '~/test/bdd'

const execute = (query: string, variables?: Record<string, unknown>) =>
  graphql({
    schema,
    source: query,
    variableValues: variables,
    contextValue: { loaders: createLoaders() },
  })

type BooksResult = {
  items: { title: string; status?: string; genre?: string }[]
  totalCount: number
  hasMore: boolean
}

feature('GraphQL query: books', () => {
  scenario('lists all books with pagination metadata', async () => {
    given('several books exist')
    await BookCommand.add(BookTitle('Germinal'), { genre: Genre('Roman naturaliste') })
    await BookCommand.add(BookTitle('Le Petit Prince'), { genre: Genre('Conte') })
    await BookCommand.add(BookTitle('Les Fleurs du Mal'), { genre: Genre('Poésie') })

    when('books query is called without filters')
    const result = await execute('{ books { items { title genre } totalCount hasMore } }')

    then('all books are returned with pagination info')
    expect(result.errors).toBeUndefined()
    const books = result.data?.books as BooksResult
    expect(books.items).toHaveLength(3)
    expect(books.totalCount).toBe(3)
    expect(books.hasMore).toBe(false)
  })

  scenario('filters books by status', async () => {
    given('books with different statuses exist')
    await BookCommand.add(BookTitle('Germinal'), { status: 'to-read' })
    await BookCommand.add(BookTitle('Le Petit Prince'), { status: 'read' })
    await BookCommand.add(BookTitle('Les Fleurs du Mal'), { status: 'to-read' })

    when('books query is called with status filter')
    const result = await execute(
      '{ books(status: "to-read") { items { title status } totalCount } }',
    )

    then('only to-read books are returned')
    expect(result.errors).toBeUndefined()
    const books = result.data?.books as BooksResult
    expect(books.items).toHaveLength(2)
    expect(books.totalCount).toBe(2)
    and('all returned books have status to-read')
    expect(books.items.every(({ status }) => status === 'to-read')).toBe(true)
  })

  scenario('sorts books by title ascending', async () => {
    given('several books exist')
    await BookCommand.add(BookTitle('Germinal'), {})
    await BookCommand.add(BookTitle('Les Fleurs du Mal'), {})
    await BookCommand.add(BookTitle('Anna Karénine'), {})

    when('books query is called with sort and order')
    const result = await execute('{ books(sort: title, order: asc) { items { title } } }')

    then('books are sorted alphabetically')
    expect(result.errors).toBeUndefined()
    const books = result.data?.books as BooksResult
    expect(books.items[0].title).toBe('Anna Karénine')
    expect(books.items[2].title).toBe('Les Fleurs du Mal')
  })

  scenario('sorts books by published date descending', async () => {
    given('books with different publication dates exist')
    await BookCommand.add(BookTitle('Old Book'), { publishedDate: new Date('1950-01-01') })
    await BookCommand.add(BookTitle('Recent Book'), { publishedDate: new Date('2023-06-15') })
    await BookCommand.add(BookTitle('No Date Book'), {})

    when('books query is called with publishedDate sort descending')
    const result = await execute('{ books(sort: publishedDate, order: desc) { items { title } } }')

    then('books are sorted by publication date, most recent first, unknown last')
    expect(result.errors).toBeUndefined()
    const books = result.data?.books as BooksResult
    expect(books.items[0].title).toBe('Recent Book')
    expect(books.items[1].title).toBe('Old Book')
    expect(books.items[2].title).toBe('No Date Book')
  })

  scenario('filters favorite books', async () => {
    given('books with different ratings exist')
    const bookA = await BookCommand.add(BookTitle('Favorite Book'), {})
    const bookB = await BookCommand.add(BookTitle('Normal Book'), {})
    await BookCommand.add(BookTitle('Unrated Book'), {})
    const favoriteReview: Review = {
      bookId: bookA.id,
      rating: Note(5),
      createdAt: new Date(),
    }
    const normalReview: Review = {
      bookId: bookB.id,
      rating: Note(3),
      createdAt: new Date(),
    }
    await ReviewCommand.create(favoriteReview)
    await ReviewCommand.create(normalReview)

    when('books query is called with isFavorite filter')
    const result = await execute('{ books(isFavorite: true) { items { title } totalCount } }')

    then('only favorite books are returned')
    expect(result.errors).toBeUndefined()
    const books = result.data?.books as BooksResult
    expect(books.items).toHaveLength(1)
    expect(books.items[0].title).toBe('Favorite Book')
    expect(books.totalCount).toBe(1)
  })

  scenario('filters books with series', async () => {
    given('books with and without series exist')
    const bookA = await BookCommand.add(BookTitle('Series Book'), {})
    await BookCommand.add(BookTitle('Standalone Book'), {})
    const series = await SeriesCommand.findOrCreate('Test Series')
    await SeriesCommand.addBook(series.id, bookA.id, SeriesLabel('Tome 1'), SeriesPosition(1))

    when('books query is called with hasSeries filter')
    const result = await execute('{ books(hasSeries: true) { items { title } totalCount } }')

    then('only books with series are returned')
    expect(result.errors).toBeUndefined()
    const books = result.data?.books as BooksResult
    expect(books.items).toHaveLength(1)
    expect(books.items[0].title).toBe('Series Book')
    expect(books.totalCount).toBe(1)
  })

  scenario('paginates with offset and limit', async () => {
    given('five books exist')
    await BookCommand.add(BookTitle('Book A'), {})
    await BookCommand.add(BookTitle('Book B'), {})
    await BookCommand.add(BookTitle('Book C'), {})
    await BookCommand.add(BookTitle('Book D'), {})
    await BookCommand.add(BookTitle('Book E'), {})

    when('first page is requested with limit 2')
    const page1 = await execute(
      '{ books(sort: title, order: asc, limit: 2) { items { title } totalCount hasMore } }',
    )

    then('2 items are returned with hasMore true')
    expect(page1.errors).toBeUndefined()
    const first = page1.data?.books as BooksResult
    expect(first.items).toHaveLength(2)
    expect(first.totalCount).toBe(5)
    expect(first.hasMore).toBe(true)

    when('last page is requested')
    const page3 = await execute(
      '{ books(sort: title, order: asc, offset: 4, limit: 2) { items { title } totalCount hasMore } }',
    )

    then('1 item is returned with hasMore false')
    const last = page3.data?.books as BooksResult
    expect(last.items).toHaveLength(1)
    expect(last.totalCount).toBe(5)
    expect(last.hasMore).toBe(false)
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
      rating: Note(4),
      readDate: new Date('2024-01-15'),
      reviewNotes: 'Excellent roman social',
      createdAt: new Date(),
    }
    await ReviewCommand.create(review)
    const series = await SeriesCommand.findOrCreate('Les Rougon-Macquart')
    await SeriesCommand.addBook(series.id, book.id, SeriesLabel('Tome 13'), SeriesPosition(13))

    when('book query is called with nested fields')
    const result = await execute(`{
      book(id: "${book.id}") {
        title
        genre
        review { rating readDate reviewNotes }
        series { id name volumes { title } }
        seriesVolume { title label position }
      }
    }`)

    then('book detail is returned with all nested data')
    expect(result.errors).toBeUndefined()
    const data = result.data?.book as Record<string, unknown>
    expect(data.title).toBe('Germinal')
    expect(data.genre).toBe('Roman naturaliste')

    and('review is included')
    const reviewData = data.review as Record<string, unknown>
    expect(reviewData.rating).toBe(4)
    expect(reviewData.reviewNotes).toBe('Excellent roman social')

    and('series is included')
    const seriesData = data.series as Record<string, unknown>
    expect(seriesData.name).toBe('Les Rougon-Macquart')

    and('series volume is included')
    const volumeData = data.seriesVolume as Record<string, unknown>
    expect(volumeData.label).toBe('Tome 13')
    expect(volumeData.position).toBe(13)
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
      book(id: "${book.id}") { title }
    }`)

    then('only the requested field is returned')
    expect(result.errors).toBeUndefined()
    const data = result.data?.book as Record<string, unknown>
    expect(data.title).toBe('Le Petit Prince')
    expect(data).not.toHaveProperty('genre')
  })
})
