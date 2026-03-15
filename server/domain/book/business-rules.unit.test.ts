import { describe, expect, test } from 'bun:test'
import { awardsCount, isFavorite, popularityScore } from '~/domain/book/business-rules'
import { Note } from '~/domain/book/primitives'
import type { Award, PublicRating } from '~/domain/book/types'

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

describe('popularityScore', () => {
  test('returns 0 for an empty array', () => {
    expect(popularityScore([])).toBe(0)
  })

  test('returns the score for a single rating', () => {
    const ratings: PublicRating[] = [
      { source: 'Babelio', score: Note(4), maxScore: Note(5), voterCount: 100 },
    ]
    expect(popularityScore(ratings)).toBe(4)
  })

  test('computes a weighted average across multiple ratings', () => {
    const ratings: PublicRating[] = [
      { source: 'Babelio', score: Note(4), maxScore: Note(5), voterCount: 100 },
      { source: 'Goodreads', score: Note(3), maxScore: Note(5), voterCount: 200 },
    ]
    // (4*100 + 3*200) / (100+200) = 1000/300 = 3.333... → rounded to 3.33
    expect(popularityScore(ratings)).toBe(3.33)
  })

  test('returns 0 when all voter counts are zero', () => {
    const ratings: PublicRating[] = [
      { source: 'Babelio', score: Note(4), maxScore: Note(5), voterCount: 0 },
    ]
    expect(popularityScore(ratings)).toBe(0)
  })
})
