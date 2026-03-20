import { describe, expect, test } from 'bun:test'
import {
  randomSeriesId,
  SeriesId,
  SeriesLabel,
  SeriesName,
  SeriesPosition,
} from '~/domain/series/primitives'

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

describe('SeriesLabel', () => {
  test('accepts a non-empty string', () => {
    expect(SeriesLabel('1')).toBe(SeriesLabel('1'))
  })

  test('accepts free-form text', () => {
    expect(SeriesLabel('Hors-série')).toBe(SeriesLabel('Hors-série'))
    expect(SeriesLabel('1.5')).toBe(SeriesLabel('1.5'))
    expect(SeriesLabel('Extra')).toBe(SeriesLabel('Extra'))
  })

  test('rejects an empty string', () => {
    expect(() => SeriesLabel('')).toThrow()
  })
})

describe('SeriesPosition', () => {
  test('accepts a positive integer', () => {
    expect(SeriesPosition(1)).toBe(SeriesPosition(1))
  })

  test('accepts a positive decimal', () => {
    expect(SeriesPosition(1.5)).toBe(SeriesPosition(1.5))
    expect(SeriesPosition(0.5)).toBe(SeriesPosition(0.5))
  })

  test('accepts a large positive number', () => {
    expect(SeriesPosition(99)).toBe(SeriesPosition(99))
  })

  test('coerces a string to number', () => {
    expect(SeriesPosition('3')).toBe(SeriesPosition(3))
    expect(SeriesPosition('1.5')).toBe(SeriesPosition(1.5))
  })

  test('rejects zero', () => {
    expect(() => SeriesPosition(0)).toThrow()
  })

  test('rejects a negative number', () => {
    expect(() => SeriesPosition(-1)).toThrow()
  })

  test('preserves decimals without rounding', () => {
    expect(SeriesPosition(1.1)).toBe(SeriesPosition(1.1))
    expect(SeriesPosition(2.3)).toBe(SeriesPosition(2.3))
  })
})
