import { describe, expect, test } from 'bun:test'
import { Asin, AudibleLocale } from '~/domain/audible/primitives'

describe('Asin', () => {
  test('accepts valid 10-char alphanumeric ASIN', () => {
    expect(String(Asin('B08G9PRS1K'))).toBe('B08G9PRS1K')
    expect(String(Asin('0062316117'))).toBe('0062316117')
  })

  test('rejects ASIN with wrong length', () => {
    expect(() => Asin('B08G9')).toThrow()
    expect(() => Asin('B08G9PRS1K123')).toThrow()
  })

  test('rejects ASIN with invalid characters', () => {
    expect(() => Asin('b08g9prs1k')).toThrow()
    expect(() => Asin('B08G9PRS-K')).toThrow()
  })

  test('rejects non-string values', () => {
    expect(() => Asin(123)).toThrow()
    expect(() => Asin(null)).toThrow()
    expect(() => Asin(undefined)).toThrow()
  })
})

describe('AudibleLocale', () => {
  test('accepts valid locales', () => {
    expect(AudibleLocale('fr')).toBe('fr')
    expect(AudibleLocale('com')).toBe('com')
    expect(AudibleLocale('co.uk')).toBe('co.uk')
    expect(AudibleLocale('de')).toBe('de')
    expect(AudibleLocale('com.au')).toBe('com.au')
    expect(AudibleLocale('co.jp')).toBe('co.jp')
  })

  test('rejects invalid locales', () => {
    expect(() => AudibleLocale('us')).toThrow()
    expect(() => AudibleLocale('uk')).toThrow()
    expect(() => AudibleLocale('')).toThrow()
    expect(() => AudibleLocale(null)).toThrow()
  })
})
