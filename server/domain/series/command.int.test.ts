import { describe, expect, test } from 'bun:test'
import { randomBookId } from '~/domain/book/primitives'
import { SeriesCommand } from '~/domain/series/command'
import { randomSeriesId, SeriesLabel, SeriesName, SeriesPosition } from '~/domain/series/primitives'
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

describe('SeriesCommand.renameSeries', () => {
  test('renames a series', async () => {
    const series = await SeriesCommand.findOrCreate('Old Name')
    const result = await SeriesCommand.renameSeries(series.id, SeriesName('New Name'))

    expect(result).not.toBe('not-found')
    expect(result).not.toBe('name-taken')
    if (result === 'not-found' || result === 'name-taken') return
    expect(result.name).toBe(SeriesName('New Name'))
    expect(result.id).toBe(series.id)
  })

  test('returns not-found for unknown ID', async () => {
    const result = await SeriesCommand.renameSeries(randomSeriesId(), SeriesName('Whatever'))
    expect(result).toBe('not-found')
  })

  test('returns name-taken when another series has the target name', async () => {
    await SeriesCommand.findOrCreate('Existing Series')
    const other = await SeriesCommand.findOrCreate('Other Series')

    const result = await SeriesCommand.renameSeries(other.id, SeriesName('Existing Series'))
    expect(result).toBe('name-taken')
  })

  test('is case-insensitive for conflict detection', async () => {
    await SeriesCommand.findOrCreate('Conflict Test')
    const other = await SeriesCommand.findOrCreate('Another Series')

    const result = await SeriesCommand.renameSeries(other.id, SeriesName('conflict test'))
    expect(result).toBe('name-taken')
  })

  test('allows renaming to a different case of the same name', async () => {
    const series = await SeriesCommand.findOrCreate('lowercase name')
    const result = await SeriesCommand.renameSeries(series.id, SeriesName('Lowercase Name'))

    expect(result).not.toBe('not-found')
    expect(result).not.toBe('name-taken')
    if (result === 'not-found' || result === 'name-taken') return
    expect(result.name).toBe(SeriesName('Lowercase Name'))
  })

  test('cleans up old name from index after rename', async () => {
    const series = await SeriesCommand.findOrCreate('Before Rename')
    await SeriesCommand.renameSeries(series.id, SeriesName('After Rename'))

    const newSeries = await SeriesCommand.findOrCreate('Before Rename')
    expect(newSeries.id).not.toBe(series.id)
  })
})
