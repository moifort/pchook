import { describe, expect, test } from 'bun:test'
import { Position, randomSeriesId, SeriesId, SeriesName } from '~/domain/series/primitives'

describe('SeriesId', () => {
  test('accepts a valid UUID', () => {
    const uuid = '550e8400-e29b-41d4-a716-446655440000'
    expect(SeriesId(uuid)).toBe(SeriesId(uuid))
  })

  test('rejects a non-UUID string', () => {
    expect(() => SeriesId('not-a-uuid')).toThrow()
  })

  test('rejects an empty string', () => {
    expect(() => SeriesId('')).toThrow()
  })
})

describe('randomSeriesId', () => {
  test('generates a valid SeriesId', () => {
    const id = randomSeriesId()
    expect(SeriesId(id)).toBe(id)
  })

  test('generates unique ids', () => {
    const id1 = randomSeriesId()
    const id2 = randomSeriesId()
    expect(id1).not.toBe(id2)
  })
})

describe('SeriesName', () => {
  test('accepts a non-empty string', () => {
    expect(SeriesName('Harry Potter')).toBe(SeriesName('Harry Potter'))
  })

  test('rejects an empty string', () => {
    expect(() => SeriesName('')).toThrow()
  })
})

describe('Position', () => {
  test('accepts a positive integer', () => {
    expect(Position(1)).toBe(Position(1))
  })

  test('accepts a large positive integer', () => {
    expect(Position(42)).toBe(Position(42))
  })

  test('coerces a string to number', () => {
    expect(Position('3')).toBe(Position(3))
  })

  test('rejects zero', () => {
    expect(() => Position(0)).toThrow()
  })

  test('rejects a negative number', () => {
    expect(() => Position(-1)).toThrow()
  })

  test('rejects a non-integer', () => {
    expect(() => Position(1.5)).toThrow()
  })
})
