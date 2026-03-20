import { describe, expect, test } from 'bun:test'
import { awardsCount, isFavorite } from '~/domain/book/business-rules'
import { Note } from '~/domain/book/primitives'
import type { Award } from '~/domain/book/types'

describe('isFavorite', () => {
  test('returns true when rating is 5', () => {
    expect(isFavorite(Note(5))).toBe(true)
  })

  test('returns false when rating is 4', () => {
    expect(isFavorite(Note(4))).toBe(false)
  })

  test('returns false when rating is undefined', () => {
    expect(isFavorite(undefined)).toBe(false)
  })
})

describe('awardsCount', () => {
  test('returns 0 for an empty array', () => {
    expect(awardsCount([])).toBe(0)
  })

  test('returns the number of awards', () => {
    const awards: Award[] = [
      { name: 'Prix Goncourt', year: 2020 },
      { name: 'Booker Prize' },
      { name: 'Pulitzer Prize', year: 2019 },
    ]
    expect(awardsCount(awards)).toBe(3)
  })
})
