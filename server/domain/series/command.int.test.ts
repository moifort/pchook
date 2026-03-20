import { describe, expect, test } from 'bun:test'
import { randomBookId } from '~/domain/book/primitives'
import { SeriesCommand } from '~/domain/series/command'
import { SeriesLabel, SeriesName, SeriesPosition } from '~/domain/series/primitives'
import { SeriesQuery } from '~/domain/series/query'

describe('SeriesCommand.findOrCreate', () => {
  test('creates a new series with the given name', async () => {
    const series = await SeriesCommand.findOrCreate('Harry Potter')

    expect(series.name).toBe(SeriesName('Harry Potter'))
    expect(series.id).toBeDefined()
    expect(series.createdAt).toBeInstanceOf(Date)
  })

  test('returns existing series when called with the same name', async () => {
    const first = await SeriesCommand.findOrCreate('Dune')
    const second = await SeriesCommand.findOrCreate('Dune')

    expect(second.id).toBe(first.id)
    expect(second.name).toBe(first.name)
  })

  test('is case-insensitive for name matching', async () => {
    const first = await SeriesCommand.findOrCreate('Foundation')
    const second = await SeriesCommand.findOrCreate('foundation')

    expect(second.id).toBe(first.id)
  })
})

describe('SeriesCommand.addBook', () => {
  test('adds a book to a series', async () => {
    const series = await SeriesCommand.findOrCreate('Discworld')
    const bookId = randomBookId()

    await SeriesCommand.addBook(series.id, bookId, SeriesLabel('1'), SeriesPosition(1))

    const result = await SeriesQuery.getByBookId(bookId)
    expect(result).not.toBeNull()
    expect(result?.id).toBe(series.id)
    expect(Number(result?.position)).toBe(1)
    expect(String(result?.label)).toBe('1')
  })

  test('adds multiple books to the same series', async () => {
    const series = await SeriesCommand.findOrCreate('Lord of the Rings')
    const bookId1 = randomBookId()
    const bookId2 = randomBookId()

    await SeriesCommand.addBook(series.id, bookId1, SeriesLabel('1'), SeriesPosition(1))
    await SeriesCommand.addBook(series.id, bookId2, SeriesLabel('2'), SeriesPosition(2))

    const result1 = await SeriesQuery.getByBookId(bookId1)
    const result2 = await SeriesQuery.getByBookId(bookId2)

    expect(result1?.id).toBe(series.id)
    expect(Number(result1?.position)).toBe(1)
    expect(result2?.id).toBe(series.id)
    expect(Number(result2?.position)).toBe(2)
  })

  test('supports decimal positions and free-form labels', async () => {
    const series = await SeriesCommand.findOrCreate('Test Series')
    const bookId = randomBookId()

    await SeriesCommand.addBook(series.id, bookId, SeriesLabel('1.5'), SeriesPosition(1.5))

    const result = await SeriesQuery.getByBookId(bookId)
    expect(Number(result?.position)).toBe(1.5)
    expect(String(result?.label)).toBe('1.5')
  })
})

describe('SeriesCommand.removeBook', () => {
  test('removes a book from its series', async () => {
    const series = await SeriesCommand.findOrCreate('Narnia')
    const bookId = randomBookId()

    await SeriesCommand.addBook(series.id, bookId, SeriesLabel('1'), SeriesPosition(1))
    await SeriesCommand.removeBook(bookId)

    const result = await SeriesQuery.getByBookId(bookId)
    expect(result).toBeNull()
  })

  test('does not affect other books in the same series', async () => {
    const series = await SeriesCommand.findOrCreate('Earthsea')
    const bookId1 = randomBookId()
    const bookId2 = randomBookId()

    await SeriesCommand.addBook(series.id, bookId1, SeriesLabel('1'), SeriesPosition(1))
    await SeriesCommand.addBook(series.id, bookId2, SeriesLabel('2'), SeriesPosition(2))
    await SeriesCommand.removeBook(bookId1)

    const removed = await SeriesQuery.getByBookId(bookId1)
    const kept = await SeriesQuery.getByBookId(bookId2)

    expect(removed).toBeNull()
    expect(kept).not.toBeNull()
    expect(kept?.id).toBe(series.id)
  })

  test('is a no-op when the book has no series', async () => {
    const bookId = randomBookId()
    await SeriesCommand.removeBook(bookId)

    const result = await SeriesQuery.getByBookId(bookId)
    expect(result).toBeNull()
  })
})
