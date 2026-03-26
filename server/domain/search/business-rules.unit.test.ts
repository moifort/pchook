import { describe, expect, test } from 'bun:test'
import { fuzzyScore, normalize, searchEntries } from '~/domain/search/business-rules'
import type { SearchEntry } from '~/domain/search/types'

describe('normalize', () => {
  test('lowercases text', () => {
    expect(normalize('Hello World')).toBe('hello world')
  })

  test('removes accents and diacritical marks', () => {
    expect(normalize('café')).toBe('cafe')
    expect(normalize('Éléphant')).toBe('elephant')
    expect(normalize('François')).toBe('francois')
    expect(normalize('naïve')).toBe('naive')
    expect(normalize('über')).toBe('uber')
  })

  test('trims whitespace', () => {
    expect(normalize('  hello  ')).toBe('hello')
  })

  test('collapses multiple spaces', () => {
    expect(normalize('hello   world')).toBe('hello world')
  })

  test('handles combined transformations', () => {
    expect(normalize('  Le Père Noël  ')).toBe('le pere noel')
  })

  test('handles empty string', () => {
    expect(normalize('')).toBe('')
  })
})

describe('fuzzyScore', () => {
  test('returns 100 for exact match (case-insensitive, accent-insensitive)', () => {
    expect(fuzzyScore('café', 'Café')).toBe(100)
    expect(fuzzyScore('hello', 'Hello')).toBe(100)
  })

  test('returns 80 for starts-with match', () => {
    expect(fuzzyScore('fond', 'Fondation')).toBe(80)
    expect(fuzzyScore('le', 'Le Petit Prince')).toBe(80)
  })

  test('returns 60 for word-starts-with match', () => {
    expect(fuzzyScore('prince', 'Le Petit Prince')).toBe(60)
    expect(fuzzyScore('petit', 'Le Petit Prince')).toBe(60)
  })

  test('returns 40 for contains match', () => {
    expect(fuzzyScore('onda', 'Fondation')).toBe(40)
  })

  test('returns 20 for Levenshtein match within distance 2', () => {
    expect(fuzzyScore('fondtion', 'Fondation')).toBe(20)
  })

  test('returns 0 for no match', () => {
    expect(fuzzyScore('xyz', 'Fondation')).toBe(0)
  })

  test('returns 0 for empty query', () => {
    expect(fuzzyScore('', 'Fondation')).toBe(0)
  })

  test('handles accent-insensitive matching', () => {
    expect(fuzzyScore('francois', 'François')).toBe(100)
    expect(fuzzyScore('eleph', 'Éléphant')).toBe(80)
  })
})

describe('searchEntries', () => {
  const entries: SearchEntry[] = [
    { type: 'book', entityId: '1', text: 'Fondation', normalizedText: 'fondation' },
    { type: 'book', entityId: '2', text: 'Le Petit Prince', normalizedText: 'le petit prince' },
    {
      type: 'series',
      entityId: '3',
      text: 'Les Rougon-Macquart',
      normalizedText: 'les rougon-macquart',
    },
    { type: 'author', entityId: 'Asimov', text: 'Isaac Asimov', normalizedText: 'isaac asimov' },
  ]

  test('returns matching entries sorted by score', () => {
    const results = searchEntries(entries, 'fond', 10)
    expect(results).toHaveLength(1)
    expect(results[0].entityId).toBe('1')
  })

  test('returns empty array for empty query', () => {
    expect(searchEntries(entries, '', 10)).toEqual([])
  })

  test('respects limit', () => {
    const results = searchEntries(entries, 'le', 1)
    expect(results).toHaveLength(1)
  })

  test('matches across types', () => {
    const results = searchEntries(entries, 'asimov', 10)
    expect(results).toHaveLength(1)
    expect(results[0].type).toBe('author')
  })

  test('returns multiple matches ordered by score', () => {
    const results = searchEntries(entries, 'le', 10)
    expect(results.length).toBeGreaterThanOrEqual(1)
    expect(results[0].text).toBe('Le Petit Prince')
  })
})
