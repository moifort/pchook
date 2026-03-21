import { describe, expect, test } from 'bun:test'
import {
  buildGeminiPrompt,
  formatDuration,
  mergeAudibleIntoScanResult,
} from '~/domain/audible/business-rules'
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

const makeGeminiResult = (overrides: Record<string, unknown> = {}): Record<string, unknown> => ({
  title: 'Le Seigneur des Anneaux',
  authors: ['J.R.R. Tolkien'],
  publisher: 'Christian Bourgois',
  publishedDate: '1954-07-29',
  pageCount: 1200,
  genre: 'Fantasy, Aventure',
  synopsis: 'Un hobbit entreprend un voyage épique...',
  isbn: '978-2-267-02700-0',
  language: 'FR',
  format: 'paperback',
  series: 'Le Seigneur des Anneaux',
  seriesNumber: 1,
  translator: 'Francis Ledoux',
  estimatedPrice: 25,
  awards: [{ name: 'Prix Hugo', year: 1966 }],
  publicRatings: [],
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

describe('buildGeminiPrompt', () => {
  test('includes title and authors', () => {
    const prompt = buildGeminiPrompt(makeItem())
    expect(prompt).toContain('"Le Seigneur des Anneaux"')
    expect(prompt).toContain('J.R.R. Tolkien')
  })

  test('includes series hint when present', () => {
    const prompt = buildGeminiPrompt(
      makeItem({ series: { name: 'Le Seigneur des Anneaux', position: 1 } }),
    )
    expect(prompt).toContain('série "Le Seigneur des Anneaux"')
    expect(prompt).toContain('tome 1')
  })

  test('includes series hint without position', () => {
    const prompt = buildGeminiPrompt(makeItem({ series: { name: 'My Series' } }))
    expect(prompt).toContain('série "My Series"')
    expect(prompt).not.toContain('tome 1')
  })

  test('omits series hint when absent', () => {
    const prompt = buildGeminiPrompt(makeItem({ series: undefined }))
    expect(prompt).not.toContain('fait partie de la série')
  })

  test('joins multiple authors', () => {
    const prompt = buildGeminiPrompt(makeItem({ authors: ['Author A', 'Author B'] }))
    expect(prompt).toContain('Author A, Author B')
  })
})

describe('mergeAudibleIntoScanResult', () => {
  test('audible data overrides gemini for title, authors, narrators, duration, publisher, language', () => {
    const result = mergeAudibleIntoScanResult(makeGeminiResult(), makeItem())

    expect(result.title).toBe('Le Seigneur des Anneaux')
    expect(result.authors).toEqual(['J.R.R. Tolkien'])
    expect(result.format).toBe('audiobook')
    expect(result.narrators).toEqual(['Thierry Janssen'])
    expect(result.duration).toBe('19h 0min')
    expect(result.publisher).toBe('Audible Studios')
    expect(result.language).toBe('fr')
  })

  test('gemini provides complement: genre, synopsis, awards, isbn, estimatedPrice', () => {
    const result = mergeAudibleIntoScanResult(makeGeminiResult(), makeItem())

    expect(result.genre).toBe('Fantasy, Aventure')
    expect(result.synopsis).toBe('Un hobbit entreprend un voyage épique...')
    expect(result.isbn).toBe('978-2-267-02700-0')
    expect(result.estimatedPrice).toBe(25)
    expect(result.awards).toEqual([{ name: 'Prix Hugo', year: 1966 }])
  })

  test('audible series overrides gemini series', () => {
    const result = mergeAudibleIntoScanResult(
      makeGeminiResult({ series: 'Wrong Series', seriesNumber: 99 }),
      makeItem({ series: { name: 'Correct Series', position: 3 } }),
    )

    expect(result.series).toBe('Correct Series')
    expect(result.seriesNumber).toBe(3)
  })

  test('falls back to gemini series when audible has none', () => {
    const result = mergeAudibleIntoScanResult(
      makeGeminiResult({ series: 'Gemini Series', seriesNumber: 2 }),
      makeItem({ series: undefined }),
    )

    expect(result.series).toBe('Gemini Series')
    expect(result.seriesNumber).toBe(2)
  })

  test('falls back to gemini publisher when audible has none', () => {
    const result = mergeAudibleIntoScanResult(
      makeGeminiResult(),
      makeItem({ publisher: undefined }),
    )
    expect(result.publisher).toBe('Christian Bourgois')
  })

  test('falls back to gemini language when audible has none', () => {
    const result = mergeAudibleIntoScanResult(makeGeminiResult(), makeItem({ language: undefined }))
    expect(result.language).toBe('FR')
  })

  test('omits duration when zero minutes', () => {
    const result = mergeAudibleIntoScanResult(makeGeminiResult(), makeItem({ durationMinutes: 0 }))
    expect(result.duration).toBeUndefined()
  })

  test('uses audible releaseDate over gemini publishedDate', () => {
    const result = mergeAudibleIntoScanResult(
      makeGeminiResult({ publishedDate: '1954-07-29' }),
      makeItem({ releaseDate: new Date('2020-09-15') }),
    )
    expect(result.publishedDate).toBe('2020-09-15')
  })

  test('uses audible releaseDate over gemini publishedDate', () => {
    const result = mergeAudibleIntoScanResult(
      makeGeminiResult({ publishedDate: '1954-07-29' }),
      makeItem({ releaseDate: new Date('2020-09-15T00:00:00.000Z') }),
    )
    expect(result.publishedDate).toBe('2020-09-15')
  })

  test('falls back to gemini publishedDate when audible has none', () => {
    const result = mergeAudibleIntoScanResult(
      makeGeminiResult({ publishedDate: '1954-07-29' }),
      makeItem({ releaseDate: undefined }),
    )
    expect(result.publishedDate).toBe('1954-07-29')
  })

  test('handles empty awards from gemini', () => {
    const result = mergeAudibleIntoScanResult(makeGeminiResult({ awards: null }), makeItem())
    expect(result.awards).toEqual([])
  })

  test('preserves translator from gemini', () => {
    const result = mergeAudibleIntoScanResult(makeGeminiResult(), makeItem())
    expect(result.translator).toBe('Francis Ledoux')
  })

  test('preserves pageCount from gemini', () => {
    const result = mergeAudibleIntoScanResult(makeGeminiResult(), makeItem())
    expect(result.pageCount).toBe(1200)
  })
})
