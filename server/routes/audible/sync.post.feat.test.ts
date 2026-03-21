import { expect, mock } from 'bun:test'
import { Asin } from '~/domain/audible/primitives'
import type { AudibleCredentials, AudibleItem } from '~/domain/audible/types'

const fakeCredentials: AudibleCredentials = {
  accessToken: 'fake-access-token',
  refreshToken: 'fake-refresh-token',
  adpToken: 'fake-adp-token',
  devicePrivateKey: 'fake-private-key',
  serial: 'FAKESERIALNUMBER1234567890ABCDEF',
  locale: 'fr',
  expiresAt: new Date(Date.now() + 3600 * 1000),
}

const fakeLibraryItems: AudibleItem[] = [
  {
    asin: Asin('B08G9PRS1K'),
    title: 'Dune',
    authors: ['Frank Herbert'],
    narrators: ['Benjamin Jungers'],
    durationMinutes: 1290,
    publisher: 'Audible Studios',
    language: 'fr',
    releaseDate: new Date('2020-01-15'),
    coverUrl: 'https://example.com/dune.jpg',
    series: { name: 'Dune', position: 1 },
    isFinished: true,
  },
  {
    asin: Asin('B07XYZTEST'),
    title: 'Neuromancien',
    authors: ['William Gibson'],
    narrators: ['Olivier Chauvel'],
    durationMinutes: 540,
    publisher: 'Audible Studios',
    language: 'fr',
    isFinished: false,
  },
]

const fakeWishlistItems: AudibleItem[] = [
  {
    asin: Asin('B09ABCDEFG'),
    title: 'Fondation',
    authors: ['Isaac Asimov'],
    narrators: ['Laurent Natrella'],
    durationMinutes: 480,
    publisher: 'Audible Studios',
    language: 'fr',
  },
]

mock.module('~/domain/audible/audible.api', () => ({
  fetchLibrary: async (credentials: AudibleCredentials) => ({
    items: fakeLibraryItems,
    credentials,
  }),
  fetchWishlist: async (credentials: AudibleCredentials) => ({
    items: fakeWishlistItems,
    credentials,
  }),
  verifyConnection: async () => {},
  refreshAccessToken: async (credentials: AudibleCredentials) => credentials,
  generateLoginUrl: async () => ({
    loginUrl: 'https://example.com',
    sessionId: 'fake',
    cookies: [],
  }),
  registerDevice: async () => fakeCredentials,
}))

mock.module('~/system/scan/gemini', () => ({
  callGemini: async () => ({
    title: 'Gemini Title',
    authors: ['Gemini Author'],
    publisher: 'Gemini Publisher',
    publishedDate: '2020-01-01',
    pageCount: 300,
    genre: 'Science-Fiction',
    synopsis: 'Un résumé du livre.',
    isbn: null,
    language: 'FR',
    format: 'paperback',
    series: null,
    seriesNumber: null,
    translator: null,
    estimatedPrice: 20,
    awards: [],
    publicRatings: [],
  }),
  buildBookJsonSchema: () => '{}',
  normalizeBookFormat: (value: string) => value,
}))

mock.module('~/system/suggestion/index', () => ({
  SuggestionGenerator: {
    generate: async () => [],
  },
}))

import { afterEach } from 'bun:test'
import { AudibleCommand } from '~/domain/audible/command'
import { AudibleUseCase, importRunner, importTaskDefinition } from '~/domain/audible/use-case'
import { BookQuery } from '~/domain/book/query'
import importCancelHandler from '~/routes/audible/import/cancel.post'
import importPauseHandler from '~/routes/audible/import/pause.post'
import importStartHandler from '~/routes/audible/import/start.post'
import importStateHandler from '~/routes/audible/import/state.get'
import statusHandler from '~/routes/audible/status.get'
import fetchHandler from '~/routes/audible/sync/fetch.post'
import verifyHandler from '~/routes/audible/sync/verify.post'
import { and, feature, given, scenario, then, when } from '~/test/bdd'
import { mockEvent } from '~/test/setup'

afterEach(async () => {
  await importRunner.reset()
})

feature('POST /audible/sync/verify', () => {
  scenario('verifies connection when credentials exist', async () => {
    given('Audible credentials are configured')
    await AudibleCommand.saveCredentials(fakeCredentials)

    when('POST /audible/sync/verify is called')
    const event = mockEvent()
    const result = await verifyHandler(event as never)

    then('it returns verified')
    expect(result.status).toBe(200)
    expect(result.data.verified).toBe(true)
  })

  scenario('returns 422 when credentials are missing', async () => {
    given('no Audible credentials are configured')

    when('POST /audible/sync/verify is called')
    const event = mockEvent()

    then('it throws a 422 error')
    await expect(verifyHandler(event as never)).rejects.toMatchObject({ statusCode: 422 })
  })
})

feature('POST /audible/sync/fetch', () => {
  scenario('accepts fetch request and starts background processing', async () => {
    given('Audible credentials are configured')
    await AudibleCommand.saveCredentials(fakeCredentials)

    when('POST /audible/sync/fetch is called')
    const result = await fetchHandler(mockEvent() as never)

    then('it returns 202 with started flag')
    expect(result.status).toBe(202)
    expect(result.data.started).toBe(true)
  })

  scenario('rejects when no credentials are configured', async () => {
    given('no Audible credentials exist')

    then('it throws a 422 error')
    await expect(fetchHandler(mockEvent() as never)).rejects.toMatchObject({ statusCode: 422 })
  })
})

feature('POST /audible/import/start', () => {
  scenario('accepts import request and starts background task', async () => {
    given('Audible credentials are configured and data was fetched')
    await AudibleCommand.saveCredentials(fakeCredentials)
    await AudibleUseCase.fetchAndStore()

    when('POST /audible/import/start is called')
    const result = await importStartHandler(mockEvent() as never)

    then('it returns 202 with started flag')
    expect(result.status).toBe(202)
    expect(result.data.started).toBe(true)

    and('the import task completes in the background')
    // Wait for background task to finish
    await new Promise((resolve) => setTimeout(resolve, 500))
  })

  scenario('rejects when no raw data was fetched', async () => {
    given('no Audible data has been fetched')
    await AudibleCommand.saveCredentials(fakeCredentials)

    when('POST /audible/import/start is called')
    const result = await importStartHandler(mockEvent() as never)

    then('it returns 202 but the task completes immediately with zero items')
    expect(result.status).toBe(202)

    // Wait for background task to finish
    await new Promise((resolve) => setTimeout(resolve, 100))

    and('the import task state shows completed with zero items')
    const state = await importRunner.getState()
    expect(state.phase).toBe('completed')
    expect(state.total).toBe(0)
  })
})

feature('GET /audible/import/state', () => {
  scenario('returns idle state when no task has run', async () => {
    when('GET /audible/import/state is called')
    const result = await importStateHandler(mockEvent() as never)

    then('it returns idle state')
    expect(result.status).toBe(200)
    expect(result.data.phase).toBe('idle')
  })
})

feature('POST /audible/import/pause', () => {
  scenario('rejects when no import is in progress', async () => {
    when('POST /audible/import/pause is called without an active import')

    then('it throws a 409 error')
    await expect(importPauseHandler(mockEvent() as never)).rejects.toMatchObject({
      statusCode: 409,
    })
  })
})

feature('POST /audible/import/cancel', () => {
  scenario('rejects when no import is in progress', async () => {
    when('POST /audible/import/cancel is called without an active import')

    then('it throws a 409 error')
    await expect(importCancelHandler(mockEvent() as never)).rejects.toMatchObject({
      statusCode: 409,
    })
  })
})

feature('Audible sync end-to-end', () => {
  scenario('imports fetched data into books via task runner', async () => {
    given('Audible credentials are configured and data was fetched')
    await AudibleCommand.saveCredentials(fakeCredentials)
    await AudibleUseCase.fetchAndStore()

    when('import task is executed directly')
    const result = await importRunner.start(importTaskDefinition)

    then('it completes successfully')
    expect(result).toBe('completed')

    and('books are created with correct format and status')
    const books = await BookQuery.findAll()
    expect(books).toHaveLength(3)

    const dune = books.find((b) => String(b.title) === 'Dune')
    expect(dune).toBeDefined()
    expect(dune?.format).toBe('audiobook')
    expect(dune?.status).toBe('read')
    expect(dune?.duration).toBe('21h 30min')
    expect(dune?.narrators?.map(String)).toEqual(['Benjamin Jungers'])

    const neuromancien = books.find((b) => String(b.title) === 'Neuromancien')
    expect(neuromancien).toBeDefined()
    expect(neuromancien?.format).toBe('audiobook')
    expect(neuromancien?.status).toBe('to-read')

    const fondation = books.find((b) => String(b.title) === 'Fondation')
    expect(fondation).toBeDefined()
    expect(fondation?.format).toBe('audiobook')
    expect(fondation?.status).toBe('to-read')
  })

  scenario('skips already-imported ASINs on re-import', async () => {
    given('Audible data was fetched and a first import was done')
    await AudibleCommand.saveCredentials(fakeCredentials)
    await AudibleUseCase.fetchAndStore()
    await importRunner.start(importTaskDefinition)

    when('import is executed again')
    const result = await importRunner.start(importTaskDefinition)

    then('task completes (items are skipped internally)')
    expect(result).toBe('completed')

    and('no duplicate books are created')
    const books = await BookQuery.findAll()
    expect(books).toHaveLength(3)
  })
})

feature('GET /audible/status', () => {
  scenario('returns status after full sync', async () => {
    given('credentials are configured and sync was performed')
    await AudibleCommand.saveCredentials(fakeCredentials)
    await AudibleUseCase.fetchAndStore()
    await importRunner.start(importTaskDefinition)

    when('GET /audible/status is called')
    const result = await statusHandler(mockEvent() as never)

    then('status shows connected with correct counts')
    expect(result.status).toBe(200)
    expect(result.data.connected).toBe(true)
    expect(result.data.libraryCount).toBe(2)
    expect(result.data.wishlistCount).toBe(1)
    expect(result.data.lastFetchedAt).toBeDefined()
    expect(result.data.rawItemCount).toBe(3)
    expect(result.data.importTask.phase).toBe('completed')
  })

  scenario('returns disconnected when no credentials', async () => {
    given('no credentials are configured')

    when('GET /audible/status is called')
    const event = mockEvent()
    const result = await statusHandler(event as never)

    then('status shows not connected')
    expect(result.status).toBe(200)
    expect(result.data.connected).toBe(false)
    expect(result.data.libraryCount).toBe(0)
    expect(result.data.wishlistCount).toBe(0)
  })
})
