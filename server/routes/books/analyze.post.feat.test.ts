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
import analyzeHandler from '~/routes/books/analyze.post'
import confirmHandler from '~/routes/books/confirm.post'
import { and, feature, given, scenario, then, when } from '~/test/bdd'
import { mockEvent } from '~/test/setup'

feature('POST /books/analyze + POST /books/confirm', () => {
  scenario('analyzes a book cover and returns a preview', async () => {
    given('an image buffer sent as raw body')
    const event = mockEvent()

    when('POST /books/analyze is called')
    const result = await analyzeHandler(event as never)

    then('a preview is returned with scan result data')
    expect(result.status).toBe(200)
    expect(result.data.previewId).toBeString()
    expect(result.data.title).toBe('Les Misérables')
    expect(result.data.authors).toEqual(['Victor Hugo'])
    expect(result.data.genre).toBe('Roman historique')

    and('no book is created yet')
    const books = await BookListReadModel.all({})
    expect(books).toHaveLength(0)
  })

  scenario('confirms a preview and creates a book', async () => {
    given('a preview has been created from a scan')
    const analyzeEvent = mockEvent()
    const analyzeResult = await analyzeHandler(analyzeEvent as never)
    const { previewId } = analyzeResult.data

    when('POST /books/confirm is called with the preview ID')
    const confirmEvent = mockEvent({ body: { previewId, status: 'to-read' } })
    const result = await confirmHandler(confirmEvent as never)

    then('a book is created with the scan result data')
    expect(result.status).toBe(201)
    expect(String(result.data.title)).toBe('Les Misérables')
    expect(result.data.status).toBe('to-read')

    and('the book appears in the list')
    const books = await BookListReadModel.all({})
    expect(books).toHaveLength(1)
  })

  scenario('confirms with read status', async () => {
    given('a preview has been created from a scan')
    const analyzeEvent = mockEvent()
    const analyzeResult = await analyzeHandler(analyzeEvent as never)
    const { previewId } = analyzeResult.data

    when('POST /books/confirm is called with status read')
    const confirmEvent = mockEvent({ body: { previewId, status: 'read' } })
    const result = await confirmHandler(confirmEvent as never)

    then('the book is created with read status')
    expect(result.status).toBe(201)
    expect(result.data.status).toBe('read')
  })

  scenario('rejects a duplicate book by ISBN on confirm', async () => {
    given('a first book has been confirmed')
    const firstAnalyze = mockEvent()
    const firstResult = await analyzeHandler(firstAnalyze as never)
    const firstConfirm = mockEvent({
      body: { previewId: firstResult.data.previewId, status: 'to-read' },
    })
    await confirmHandler(firstConfirm as never)

    and('a second preview is created for the same book')
    const secondAnalyze = mockEvent()
    const secondResult = await analyzeHandler(secondAnalyze as never)

    when('POST /books/confirm is called for the duplicate')
    const secondConfirm = mockEvent({
      body: { previewId: secondResult.data.previewId, status: 'to-read' },
    })
    const result = await confirmHandler(secondConfirm as never)

    then('it returns 409 with the existing book')
    expect(result.status).toBe(409)
    expect(String(result.data.title)).toBe('Les Misérables')

    and('no duplicate is created')
    const books = await BookListReadModel.all({})
    expect(books).toHaveLength(1)
  })
})
