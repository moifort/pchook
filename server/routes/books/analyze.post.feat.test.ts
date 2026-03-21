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
  publicRatings: [],
}

mock.module('~/system/scan/index', () => ({
  BookScanner: {
    scan: async () => fakeScanResult,
  },
}))

import { BookListReadModel } from '~/read-model/book-list/index'
import analyzeHandler from '~/routes/books/analyze.post'
import confirmHandler from '~/routes/books/confirm.post'
import { and, feature, given, scenario, then, when } from '~/test/bdd'
import { mockEvent } from '~/test/setup'

const analyzeBody = { imageBase64: 'ZmFrZS1pbWFnZS1kYXRh', ocrText: undefined }

feature('POST /books/analyze + POST /books/confirm', () => {
  scenario('analyzes a book cover and returns a preview', async () => {
    given('an image sent as base64 in JSON body')
    const event = mockEvent({ body: analyzeBody })

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
    const analyzeEvent = mockEvent({ body: analyzeBody })
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
    const analyzeEvent = mockEvent({ body: analyzeBody })
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
    const firstAnalyze = mockEvent({ body: analyzeBody })
    const firstResult = await analyzeHandler(firstAnalyze as never)
    const firstConfirm = mockEvent({
      body: { previewId: firstResult.data.previewId, status: 'to-read' },
    })
    await confirmHandler(firstConfirm as never)

    and('a second preview is created for the same book')
    const secondAnalyze = mockEvent({ body: analyzeBody })
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

  scenario('replaces a duplicate book with new scan data', async () => {
    given('a first book has been confirmed')
    const firstAnalyze = mockEvent({ body: analyzeBody })
    const firstResult = await analyzeHandler(firstAnalyze as never)
    const firstConfirm = mockEvent({
      body: { previewId: firstResult.data.previewId, status: 'read' },
    })
    const created = await confirmHandler(firstConfirm as never)
    const existingBookId = created.data.id

    and('a second preview is created for the same book')
    const secondAnalyze = mockEvent({ body: analyzeBody })
    const secondResult = await analyzeHandler(secondAnalyze as never)

    and('the duplicate is detected')
    const duplicateConfirm = mockEvent({
      body: { previewId: secondResult.data.previewId, status: 'to-read' },
    })
    const duplicateResult = await confirmHandler(duplicateConfirm as never)
    expect(duplicateResult.status).toBe(409)

    when('POST /books/confirm is called with replaceBookId')
    const thirdAnalyze = mockEvent({ body: analyzeBody })
    const thirdResult = await analyzeHandler(thirdAnalyze as never)
    const replaceConfirm = mockEvent({
      body: {
        previewId: thirdResult.data.previewId,
        status: 'to-read',
        replaceBookId: String(existingBookId),
      },
    })
    const result = await confirmHandler(replaceConfirm as never)

    then('the existing book is updated')
    expect(result.status).toBe(200)
    expect(String(result.data.id)).toBe(String(existingBookId))
    expect(String(result.data.title)).toBe('Les Misérables')

    and('the book preserves its original status when overridden')
    expect(result.data.status).toBe('to-read')

    and('no extra book is created')
    const books = await BookListReadModel.all({})
    expect(books).toHaveLength(1)
  })

  scenario('preserves the preview on duplicate for later replacement', async () => {
    given('a first book has been confirmed')
    const firstAnalyze = mockEvent({ body: analyzeBody })
    const firstResult = await analyzeHandler(firstAnalyze as never)
    const firstConfirm = mockEvent({
      body: { previewId: firstResult.data.previewId, status: 'to-read' },
    })
    const created = await confirmHandler(firstConfirm as never)

    and('a second scan triggers a duplicate')
    const secondAnalyze = mockEvent({ body: analyzeBody })
    const secondResult = await analyzeHandler(secondAnalyze as never)
    const secondPreviewId = secondResult.data.previewId

    const duplicateConfirm = mockEvent({
      body: { previewId: secondPreviewId, status: 'to-read' },
    })
    await confirmHandler(duplicateConfirm as never)

    when('the same preview is used for replacement')
    const replaceConfirm = mockEvent({
      body: {
        previewId: secondPreviewId,
        status: 'to-read',
        replaceBookId: String(created.data.id),
      },
    })
    const result = await confirmHandler(replaceConfirm as never)

    then('the replacement succeeds using the preserved preview')
    expect(result.status).toBe(200)
  })
})
