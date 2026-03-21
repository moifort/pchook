import { expect, mock } from 'bun:test'
import type { ScanResult } from '~/system/scan/types'

const fakeScanResult: ScanResult = {
  title: 'Dune',
  authors: ['Frank Herbert'],
  publisher: 'Pocket',
  publishedDate: '1965-08-01',
  pageCount: 928,
  genre: 'Science-fiction',
  synopsis:
    "Sur la planète désertique Arrakis, l'épice est la substance la plus précieuse de l'univers.",
  isbn: '9782266320481',
  language: 'FR',
  format: 'pocket',
  series: 'Dune',
  seriesNumber: 1,
  translator: undefined,
  estimatedPrice: 9.7,
  awards: [{ name: 'Prix Hugo', year: 1966 }],
  publicRatings: [],
}

mock.module('~/system/scan/isbn-scanner', () => ({
  IsbnScanner: {
    scan: async () => ({ result: fakeScanResult }),
  },
}))

import analyzeIsbnHandler from '~/routes/books/analyze-isbn.post'
import confirmHandler from '~/routes/books/confirm.post'
import { feature, given, scenario, then, when } from '~/test/bdd'
import { mockEvent } from '~/test/setup'

feature('POST /books/analyze-isbn', () => {
  scenario('analyzes an ISBN and returns a preview', async () => {
    given('a valid ISBN')
    const event = mockEvent({ body: { isbn: '9782266320481' } })

    when('POST /books/analyze-isbn is called')
    const result = await analyzeIsbnHandler(event as never)

    then('a preview is returned with book data')
    expect(result.status).toBe(200)
    if (result.status !== 200) return
    expect(result.data.previewId).toBeString()
    expect(result.data.title).toBe('Dune')
    expect(result.data.authors).toEqual(['Frank Herbert'])
    expect(result.data.genre).toBe('Science-fiction')
  })

  scenario('returns 409 when ISBN already exists in library', async () => {
    given('a first book has been confirmed with this ISBN')
    const firstAnalyze = mockEvent({ body: { isbn: '9782266320481' } })
    const firstResult = await analyzeIsbnHandler(firstAnalyze as never)
    if (firstResult.status !== 200) throw new Error('Expected 200 from first analyze')
    const firstConfirm = mockEvent({
      body: { previewId: firstResult.data.previewId, status: 'to-read' },
    })
    await confirmHandler(firstConfirm as never)

    when('POST /books/analyze-isbn is called with the same ISBN')
    const event = mockEvent({ body: { isbn: '9782266320481' } })
    const result = await analyzeIsbnHandler(event as never)

    then('it returns 409 with the existing book info')
    expect(result.status).toBe(409)
    expect(result.data.title).toBeDefined()
  })

  scenario('analyzes ISBN then confirms to create a book', async () => {
    given('a preview has been created from an ISBN scan')
    const analyzeEvent = mockEvent({ body: { isbn: '9782266320481' } })
    const analyzeResult = await analyzeIsbnHandler(analyzeEvent as never)
    if (analyzeResult.status !== 200) throw new Error('Expected 200 from analyze')
    const { previewId } = analyzeResult.data

    when('POST /books/confirm is called with the preview ID')
    const confirmEvent = mockEvent({ body: { previewId, status: 'to-read' } })
    const result = await confirmHandler(confirmEvent as never)

    then('a book is created with the scan result data')
    expect(result.status).toBe(201)
    expect(String(result.data.title)).toBe('Dune')
  })

  scenario('returns 500 when Gemini lookup fails', async () => {
    given('Gemini will fail for this ISBN')
    mock.module('~/system/scan/isbn-scanner', () => ({
      IsbnScanner: {
        scan: async () => {
          throw new Error('Gemini API unavailable')
        },
      },
    }))

    when('POST /books/analyze-isbn is called')
    const event = mockEvent({ body: { isbn: '9782266320481' } })

    then('it throws an error')
    expect(analyzeIsbnHandler(event as never)).rejects.toThrow()
  })
})
