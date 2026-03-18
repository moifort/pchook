import { describe, expect, test } from 'bun:test'
import { audibleItemToBookData, formatDuration } from '~/domain/audible/business-rules'
import { Asin } from '~/domain/audible/primitives'
import type { AudibleItem } from '~/domain/audible/types'

const makeItem = (overrides: Partial<AudibleItem> = {}): AudibleItem => ({
  asin: Asin('B08G9PRS1K'),
  title: 'Le Seigneur des Anneaux',
  authors: ['J.R.R. Tolkien'],
  narrators: ['Thierry Janssen'],
  durationMinutes: 1140,
  publisher: 'Audible Studios',
  language: 'fr',
  releaseDate: new Date('2020-09-15'),
  coverUrl: 'https://m.media-amazon.com/images/I/cover.jpg',
  ...overrides,
})

describe('formatDuration', () => {
  test('formats hours and minutes', () => {
    expect(formatDuration(90)).toBe('1h 30min')
  })

  test('formats exact hours', () => {
    expect(formatDuration(120)).toBe('2h 0min')
  })

  test('formats zero minutes', () => {
    expect(formatDuration(0)).toBe('0h 0min')
  })

  test('formats large durations', () => {
    expect(formatDuration(1140)).toBe('19h 0min')
  })

  test('formats minutes only', () => {
    expect(formatDuration(45)).toBe('0h 45min')
  })
})

describe('audibleItemToBookData', () => {
  test('maps library item with read status', () => {
    const result = audibleItemToBookData(makeItem(), 'library')
    expect(String(result.title)).toBe('Le Seigneur des Anneaux')
    expect(result.data.status).toBe('read')
    expect(result.data.format).toBe('audiobook')
    expect(result.data.authors?.map(String)).toEqual(['J.R.R. Tolkien'])
    expect(result.data.narrators?.map(String)).toEqual(['Thierry Janssen'])
    expect(result.data.duration).toBe('19h 0min')
    expect(String(result.data.publisher)).toBe('Audible Studios')
    expect(String(result.data.language)).toBe('fr')
    expect(result.data.publishedDate).toEqual(new Date('2020-09-15'))
    expect(result.coverUrl).toBe('https://m.media-amazon.com/images/I/cover.jpg')
  })

  test('maps wishlist item with to-read status', () => {
    const result = audibleItemToBookData(makeItem(), 'wishlist')
    expect(result.data.status).toBe('to-read')
    expect(result.data.format).toBe('audiobook')
  })

  test('maps series info', () => {
    const result = audibleItemToBookData(
      makeItem({ series: { name: 'Le Seigneur des Anneaux', position: 1 } }),
      'library',
    )
    expect(result.seriesInfo).toEqual({ name: 'Le Seigneur des Anneaux', number: 1 })
  })

  test('handles missing series', () => {
    const result = audibleItemToBookData(makeItem({ series: undefined }), 'library')
    expect(result.seriesInfo).toBeUndefined()
  })

  test('handles missing duration', () => {
    const result = audibleItemToBookData(makeItem({ durationMinutes: 0 }), 'library')
    expect(result.data.duration).toBeUndefined()
  })

  test('handles missing optional fields', () => {
    const result = audibleItemToBookData(
      makeItem({
        publisher: undefined,
        language: undefined,
        releaseDate: undefined,
        coverUrl: undefined,
      }),
      'library',
    )
    expect(result.data.publisher).toBeUndefined()
    expect(result.data.language).toBeUndefined()
    expect(result.data.publishedDate).toBeUndefined()
    expect(result.coverUrl).toBeUndefined()
  })

  test('maps multiple authors and narrators', () => {
    const result = audibleItemToBookData(
      makeItem({
        authors: ['Author A', 'Author B'],
        narrators: ['Narrator X', 'Narrator Y'],
      }),
      'library',
    )
    expect(result.data.authors?.map(String)).toEqual(['Author A', 'Author B'])
    expect(result.data.narrators?.map(String)).toEqual(['Narrator X', 'Narrator Y'])
  })

  test('handles series without position', () => {
    const result = audibleItemToBookData(makeItem({ series: { name: 'My Series' } }), 'library')
    expect(result.seriesInfo).toEqual({ name: 'My Series', number: undefined })
  })
})
