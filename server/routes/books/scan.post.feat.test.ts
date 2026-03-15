import { expect, mock } from 'bun:test'
import type { ScanResult } from '~/system/scan/types'

const fakeScanResult: ScanResult = {
  title: 'Les Misérables',
  authors: ['Victor Hugo'],
  publisher: 'Gallimard',
  publishedDate: '1862-04-03',
  pageCount: 1232,
  genre: 'Roman historique',
  synopsis: "L'histoire de Jean Valjean dans la France du XIXe siècle.",
  isbn: '978-2070409228',
  language: 'Français',
  format: 'paperback',
  series: 'Les Classiques',
  seriesNumber: 1,
  translator: undefined,
  estimatedPrice: 12.5,
  awards: [{ name: 'Prix littéraire', year: 2025 }],
  publicRatings: [{ source: 'Babelio', score: 4, maxScore: 5, voterCount: 5000 }],
}

mock.module('~/system/scan/index', () => ({
  BookScanner: {
    scan: async () => fakeScanResult,
  },
}))

mock.module('~/system/suggestion/index', () => ({
  SuggestionGenerator: {
    generate: async () => [],
  },
}))

// @ts-expect-error — global mock for h3's readRawBody
globalThis.readRawBody = async () => Buffer.from('fake-image-data')

import { BookListReadModel } from '~/read-model/book-list/index'
import scanHandler from '~/routes/books/scan.post'
import { and, feature, given, scenario, then, when } from '~/test/bdd'
import { mockEvent } from '~/test/setup'

feature('POST /books/scan', () => {
  scenario('scans a book cover and creates a book', async () => {
    given('an image buffer sent as raw body')
    const event = mockEvent()

    when('POST /books/scan is called')
    const result = await scanHandler(event as never)

    then('a book is created with the scan result data')
    expect(result.status).toBe(201)
    expect(String(result.data.title)).toBe('Les Misérables')
    expect(result.data.authors).toHaveLength(1)
    expect(String(result.data.genre)).toBe('Roman historique')
    expect(result.data.status).toBe('to-read')
    expect(String(result.data.isbn)).toBe('978-2070409228')
    expect(Number(result.data.pageCount)).toBe(1232)

    and('the book appears in the list')
    const books = await BookListReadModel.all({})
    expect(books).toHaveLength(1)
    expect(books[0].title).toBe('Les Misérables')
  })
})
