import { describe, expect, test } from 'bun:test'
import { Language } from '~/domain/book/primitives'
import { booksInLanguage } from '~/domain/series/business-rules'

const book = (id: string, language?: string) => ({
  id,
  language: language ? Language(language) : undefined,
})

describe('booksInLanguage', () => {
  test('returns only books with matching language', () => {
    const books = [book('1', 'FR'), book('2', 'EN'), book('3', 'FR')]
    expect(booksInLanguage(books, Language('FR'))).toEqual([books[0], books[2]])
  })

  test('returns books without language when filter language is undefined', () => {
    const books = [book('1', 'FR'), book('2'), book('3')]
    expect(booksInLanguage(books, undefined)).toEqual([books[1], books[2]])
  })

  test('returns empty array when no books match', () => {
    const books = [book('1', 'FR'), book('2', 'FR')]
    expect(booksInLanguage(books, Language('EN'))).toEqual([])
  })

  test('matches undefined language on both sides', () => {
    const books = [book('1'), book('2')]
    expect(booksInLanguage(books, undefined)).toEqual([books[0], books[1]])
  })
})
